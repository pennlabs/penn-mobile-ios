//
//  DiningAnalyticsViewModel.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 3/27/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import SwiftUI

struct DiningAnalyticsBalance: Codable {
    let date: Date
    let balance: Double
}

class DiningAnalyticsViewModel: ObservableObject {
    static let dollarHistoryDirectory = "diningAnalyticsDollarData"
    static let swipeHistoryDirectory = "diningAnalyticsSwipeData"
    @Published var dollarHistory: [DiningAnalyticsBalance] = Storage.fileExists(dollarHistoryDirectory, in: .documents) ? Storage.retrieve(dollarHistoryDirectory, from: .documents, as: [DiningAnalyticsBalance].self) : []
    @Published var swipeHistory: [DiningAnalyticsBalance] = Storage.fileExists(swipeHistoryDirectory, in: .documents) ? Storage.retrieve(swipeHistoryDirectory, from: .documents, as: [DiningAnalyticsBalance].self) : []

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
    }
    func clearStorageIfNewSemester() {
        if Storage.fileExists(DiningAnalyticsViewModel.dollarHistoryDirectory, in: .documents), let nextAnalyticsStartDate = Storage.retrieve(DiningAnalyticsViewModel.dollarHistoryDirectory, from: .documents, as: [DiningAnalyticsBalance].self).last?.date,
            nextAnalyticsStartDate < Date.startOfSemester {
            self.dollarHistory = []
            self.swipeHistory = []
            Storage.remove(DiningAnalyticsViewModel.dollarHistoryDirectory, from: .documents)
            Storage.remove(DiningAnalyticsViewModel.swipeHistoryDirectory, from: .documents)
        }
    }
    func refresh() {
        guard let diningToken = KeychainAccessible.instance.getDiningToken() else {
            return
        }
        var startDate = dollarHistory.last?.date ?? Date.startOfSemester
        if startDate != Date.startOfSemester {
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        let startDateStr = formatter.string(from: startDate)
        var planStartDate: Date?
        DiningAPI.instance.getDiningPlanStartDate(diningToken: diningToken) { (startDate) in
            planStartDate = startDate
        }
        DiningAPI.instance.getPastDiningBalances(diningToken: diningToken, startDate: startDateStr) { (balances) in
            guard let balances = balances else {
                return
            }
            if startDateStr != self.formatter.string(from: Date()) {
                let newDollarHistory = balances.map({DiningAnalyticsBalance(date: self.formatter.date(from: $0.date)!, balance: Double($0.diningDollars) ?? 0.0)})
                let newSwipeHistory = balances.map({DiningAnalyticsBalance(date: self.formatter.date(from: $0.date)!, balance: Double($0.regularVisits))})
                self.swipeHistory.append(contentsOf: newSwipeHistory)
                self.dollarHistory.append(contentsOf: newDollarHistory)
                Storage.store(self.swipeHistory, to: .documents, as: DiningAnalyticsViewModel.swipeHistoryDirectory)
                Storage.store(self.dollarHistory, to: .documents, as: DiningAnalyticsViewModel.dollarHistoryDirectory)
            }
            guard let lastDollarBalance = self.dollarHistory.last,
                  let lastSwipeBalance = self.swipeHistory.last else {
                return
            }
            guard var startDollarBalance = (self.dollarHistory.max { $0.balance < $1.balance }),
                  var startSwipeBalance = (self.swipeHistory.max { $0.balance < $1.balance }) else {
                return
            }
            if planStartDate != nil {
                startDollarBalance = (self.dollarHistory.first { $0.date == planStartDate }) ?? startDollarBalance
                startSwipeBalance = (self.swipeHistory.first { $0.date == planStartDate }) ?? startSwipeBalance
            }
            let dollarPredictions = self.getPredictions(firstBalance: startDollarBalance, lastBalance: lastDollarBalance)
            self.dollarSlope = dollarPredictions.slope
            self.dollarPredictedZeroDate = dollarPredictions.predictedZeroDate
            self.predictedDollarSemesterEndBalance = dollarPredictions.predictedEndBalance
            self.dollarAxisLabel = self.getAxisLabelsYX(from: self.dollarHistory)
            let swipePredictions = self.getPredictions(firstBalance: startSwipeBalance, lastBalance: lastSwipeBalance)
            self.swipeSlope = swipePredictions.slope
            self.swipesPredictedZeroDate = swipePredictions.predictedZeroDate
            self.predictedSwipesSemesterEndBalance = swipePredictions.predictedEndBalance
            self.swipeAxisLabel = self.getAxisLabelsYX(from: self.swipeHistory)
        }
    }
    func getPredictions(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance) -> (slope: Double, predictedZeroDate: Date, predictedEndBalance: Double) {
        if firstBalance.date == lastBalance.date || firstBalance.balance == lastBalance.balance {
            let zeroDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.endOfSemester)!
            return (Double(0.0), zeroDate, lastBalance.balance)
        } else {
            // This is the slope needed to calculate zeroDate and endBalance
            var slope = self.getSlope(firstBalance: firstBalance, lastBalance: lastBalance)
            let zeroDate = self.predictZeroDate(firstBalance: firstBalance, lastBalance: lastBalance, slope: slope)
            let endBalance = self.predictSemesterEndBalance(firstBalance: firstBalance, lastBalance: lastBalance, slope: slope)
            let fullSemester = firstBalance.date.distance(to: Date.endOfSemester)
            let fullZeroDistance = firstBalance.date.distance(to: zeroDate)
            let deltaX = fullZeroDistance / fullSemester
            slope = -1 / deltaX // Resetting slope to different value for graph format
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
    func getAxisLabelsYX(from trans: [DiningAnalyticsBalance]) -> ([String], [String]) {
        let xAxisLabelCount = 4
        let yAxisLabelCount = 5
        var xLabels: [String] = []
        var yLabels: [String] = []

        // Generate Y Axis Labels
        let maxDollarValue = trans.max(by: { $0.balance < $1.balance })?.balance ?? 1.0
        let dollarStep = (maxDollarValue / Double(yAxisLabelCount - 1))
        for i in 0 ..< yAxisLabelCount {
            let yAxisLabel = "\(Int(dollarStep * Double(yAxisLabelCount - i - 1)))"
            yLabels.append(yAxisLabel)
        }

        // Generate X Axis Labels
        let semester = Date.startOfSemester.distance(to: Date.endOfSemester)
        let semesterStep = semester / Double(xAxisLabelCount - 1)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        for i in 0 ..< xAxisLabelCount {
            let dateForLabel = Date.startOfSemester.advanced(by: semesterStep * Double(i))
            xLabels.append(dateFormatter.string(from: dateForLabel))
        }

        return (yLabels, xLabels)
    }
}
