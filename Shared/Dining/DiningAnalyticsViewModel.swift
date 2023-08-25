//
//  DiningAnalyticsViewModel.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 3/27/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

struct DiningAnalyticsBalance: Codable, Equatable, Identifiable {
    let date: Date
    let balance: Double
    var id: Date {date}
}

extension DiningAnalyticsBalance: Comparable {
    static func <(lhs: DiningAnalyticsBalance, rhs: DiningAnalyticsBalance) -> Bool {
        if lhs.balance < rhs.balance {
            return true
        } else if lhs.balance > rhs.balance {
            return false
        } else {
            return lhs.date < rhs.date
        }
    }
}

class DiningAnalyticsViewModel: ObservableObject {
    static let dollarHistoryDirectory = "diningAnalyticsDollarData"
    static let swipeHistoryDirectory = "diningAnalyticsSwipeData"
    static let planStartDateDirectory = "diningAnalyticsPlanStartDate"
    @Published var dollarHistory: [DiningAnalyticsBalance] = Storage.fileExists(dollarHistoryDirectory, in: .groupDocuments) ? Storage.retrieve(dollarHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self) : []
    @Published var swipeHistory: [DiningAnalyticsBalance] = Storage.fileExists(swipeHistoryDirectory, in: .groupDocuments) ? Storage.retrieve(swipeHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self) : []
    @Published var planStartDate: Date? = try? Storage.retrieveThrowing(planStartDateDirectory, from: .groupDocuments, as: Date.self)

    @Published var dollarPredictedZeroDate: Date = Date.endOfSemester
    @Published var predictedDollarSemesterEndBalance: Double = 0
    @Published var swipesPredictedZeroDate: Date = Date.endOfSemester
    @Published var predictedSwipesSemesterEndBalance: Double = 0
    @Published var swipeAxisLabel: ([String], [String]) = ([], [])
    @Published var dollarAxisLabel: ([String], [String]) = ([], [])
    @Published var dollarSlope: Double = 0.0
    @Published var swipeSlope: Double = 0.0

    var yIntercept = 0.0
    var slope = 0.0
    let formatter = DateFormatter()

    init() {
        formatter.dateFormat = "yyyy-MM-dd"
        clearStorageIfNewSemester()
        populateAxesAndPredictions()
    }
    func clearStorageIfNewSemester() {
        if Storage.fileExists(DiningAnalyticsViewModel.dollarHistoryDirectory, in: .groupDocuments), let nextAnalyticsStartDate = Storage.retrieve(DiningAnalyticsViewModel.dollarHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self).last?.date,
            nextAnalyticsStartDate < Date.startOfSemester {
            self.dollarHistory = []
            self.swipeHistory = []
            self.planStartDate = nil
            Storage.remove(DiningAnalyticsViewModel.dollarHistoryDirectory, from: .groupDocuments)
            Storage.remove(DiningAnalyticsViewModel.swipeHistoryDirectory, from: .groupDocuments)
            Storage.remove(DiningAnalyticsViewModel.planStartDateDirectory, from: .groupDocuments)
        }
    }
    func refresh(refreshWidgets: Bool = false) async {
        guard let diningToken = KeychainAccessible.instance.getDiningToken() else {
            return
        }
        var startDate = dollarHistory.last?.date ?? Date.startOfSemester
        if startDate != Date.startOfSemester {
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        let startDateStr = formatter.string(from: startDate)
        let balances = await DiningAPI.instance.getPastDiningBalances(diningToken: diningToken, startDate: startDateStr)
        switch balances {
        case .failure:
            return
        case .success(let balanceList):
            if startDateStr != self.formatter.string(from: Date()) {
                let newDollarHistory = balanceList.map({DiningAnalyticsBalance(date: self.formatter.date(from: $0.date)!, balance: Double($0.diningDollars) ?? 0.0)})
                let newSwipeHistory = balanceList.map({DiningAnalyticsBalance(date: self.formatter.date(from: $0.date)!, balance: Double($0.regularVisits))})
                self.swipeHistory.append(contentsOf: newSwipeHistory)
                self.dollarHistory.append(contentsOf: newDollarHistory)
                try? Storage.storeThrowing(self.swipeHistory, to: .groupDocuments, as: DiningAnalyticsViewModel.swipeHistoryDirectory)
                try? Storage.storeThrowing(self.dollarHistory, to: .groupDocuments, as: DiningAnalyticsViewModel.dollarHistoryDirectory)
            }
            let planStartDateResult = await DiningAPI.instance.getDiningPlanStartDate(diningToken: diningToken)
            if let planStartDate = try? planStartDateResult.get() {
                self.planStartDate = planStartDate
                try? Storage.storeThrowing(planStartDate, to: .groupDocuments, as: Self.planStartDateDirectory)
            }
            if refreshWidgets {
                WidgetKind.diningAnalyticsWidgets.forEach {
                    WidgetCenter.shared.reloadTimelines(ofKind: $0)
                }
            }
            populateAxesAndPredictions()
        }
    }

    func populateAxesAndPredictions() {
        filterData()
        guard let lastDollarBalance = self.dollarHistory.last,
              let lastSwipeBalance = self.swipeHistory.last else {
            return
        }
        guard let maxDollarBalance = (self.dollarHistory.max { $0.balance < $1.balance }),
              let maxSwipeBalance = (self.swipeHistory.max { $0.balance < $1.balance }) else {
            return
        }
        // If no dining plan found, refresh will return, these are just placeholders
        var startDollarBalance = maxDollarBalance
        var startSwipeBalance = maxSwipeBalance
        guard let planStartDate else { return }

        // If dining plan found, start prediction from the date dining plan started
        startDollarBalance = (self.dollarHistory.first { $0.date == planStartDate }) ?? startDollarBalance
        startSwipeBalance = (self.swipeHistory.first { $0.date == planStartDate }) ?? startSwipeBalance
        // However, it's possible that people recharged dining dollars (swipes maybe?), and if so, predict from this date (most recent increase)
        for (i, day) in self.dollarHistory.enumerated() {
            if i != 0 && day.date > planStartDate && day.balance > self.dollarHistory[i - 1].balance {
                startDollarBalance = day
            }
        }
        for (i, day) in self.swipeHistory.enumerated() {
            if i != 0 && day.date > planStartDate && day.balance > self.swipeHistory[i - 1].balance {
                startSwipeBalance = day
            }
        }

        let dollarPredictions = self.getPredictions(firstBalance: startDollarBalance, lastBalance: lastDollarBalance, maxBalance: maxDollarBalance)
        self.dollarSlope = dollarPredictions.slope
        self.dollarPredictedZeroDate = dollarPredictions.predictedZeroDate
        self.predictedDollarSemesterEndBalance = dollarPredictions.predictedEndBalance
        self.dollarAxisLabel = self.getAxisLabelsYX(from: self.dollarHistory)
        let swipePredictions = self.getPredictions(firstBalance: startSwipeBalance, lastBalance: lastSwipeBalance, maxBalance: maxSwipeBalance)
        self.swipeSlope = swipePredictions.slope
        self.swipesPredictedZeroDate = swipePredictions.predictedZeroDate
        self.predictedSwipesSemesterEndBalance = swipePredictions.predictedEndBalance
        self.swipeAxisLabel = self.getAxisLabelsYX(from: self.swipeHistory)
    }
    
    func filterData() {
        if self.dollarHistory.count >= 2 {
            self.dollarHistory = self.dollarHistory.enumerated().filter { index, dollar in
                guard index > 0 && index < self.dollarHistory.count - 1 else {
                    return true
                }
                let previousBalance = self.dollarHistory[index - 1].balance
                let nextBalance = self.dollarHistory[index + 1].balance
                return dollar.balance != 0 || previousBalance <= 0 || nextBalance <= 0
            }.map { $0.element }
        }
        if self.swipeHistory.count >= 2 {
            self.swipeHistory = self.swipeHistory.enumerated().filter { index, swipe in
                guard index > 0 && index < self.swipeHistory.count - 1 else {
                    return true
                }
                let previousBalance = self.swipeHistory[index - 1].balance
                let nextBalance = self.swipeHistory[index + 1].balance
                return swipe.balance != 0 || previousBalance <= 0 || nextBalance <= 0
            }.map { $0.element }
        }
    }

    func getPredictions(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance, maxBalance: DiningAnalyticsBalance) -> (slope: Double, predictedZeroDate: Date, predictedEndBalance: Double) {
        if firstBalance.date == lastBalance.date || firstBalance.balance == lastBalance.balance {
            let zeroDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.endOfSemester)!
            return (Double(0.0), zeroDate, lastBalance.balance)
        } else {
            // This is the slope needed to calculate zeroDate and endBalance
            var slope = self.getSlope(firstBalance: firstBalance, lastBalance: lastBalance)
            let zeroDate = self.predictZeroDate(firstBalance: firstBalance, lastBalance: lastBalance, slope: slope)
            let endBalance = self.predictSemesterEndBalance(firstBalance: firstBalance, lastBalance: lastBalance, slope: slope)
            let fullSemester = Date.startOfSemester.distance(to: Date.endOfSemester)
            let fullZeroDistance = firstBalance.date.distance(to: zeroDate)
            let deltaX = fullZeroDistance / fullSemester
            let deltaY = firstBalance.balance / maxBalance.balance
            slope = -deltaY / deltaX // Resetting slope to different value for graph format
            return (slope, zeroDate, endBalance)
        }
    }
    func getSlope(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance) -> Double {
        let balanceDiff = lastBalance.balance - firstBalance.balance
        let timeDiff = Double(Calendar.current.dateComponents([.day], from: firstBalance.date, to: lastBalance.date).day!)
        return balanceDiff / timeDiff
    }
    func predictZeroDate(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance, slope: Double) -> Date {
        let offset = -firstBalance.balance / slope
        let zeroDate = Calendar.current.date(byAdding: .day, value: Int(offset), to: firstBalance.date)!
        return zeroDate
    }
    func predictSemesterEndBalance(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance, slope: Double) -> Double {
        let diffInDays = Calendar.current.dateComponents([.day], from: firstBalance.date, to: Date.endOfSemester).day!
        let endBalance = (slope * Double(diffInDays)) + firstBalance.balance
        return endBalance
    }
    // Compute axis labels
    static func getAxisLabelsX() -> [String] {
        let xAxisLabelCount = 4
        let semester = Date.startOfSemester.distance(to: Date.endOfSemester)
        let semesterStep = semester / Double(xAxisLabelCount - 1)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return stride(from: 0, to: Double(xAxisLabelCount), by: 1).map {
            dateFormatter.string(from: Date.startOfSemester.advanced(by: semesterStep * $0))
        }
    }
    func getAxisLabelsYX(from trans: [DiningAnalyticsBalance]) -> ([String], [String]) {
        let yAxisLabelCount = 5
        var yLabels: [String] = []

        // Generate Y Axis Labels
        let maxDollarValue = trans.max(by: { $0.balance < $1.balance })?.balance ?? 1.0
        let dollarStep = (maxDollarValue / Double(yAxisLabelCount - 1))
        for i in 0 ..< yAxisLabelCount {
            let yAxisLabel = "\(Int(dollarStep * Double(yAxisLabelCount - i - 1)))"
            yLabels.append(yAxisLabel)
        }

        return (yLabels, DiningAnalyticsViewModel.getAxisLabelsX())
    }
}
