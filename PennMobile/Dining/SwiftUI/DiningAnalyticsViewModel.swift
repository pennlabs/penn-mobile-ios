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
    
    // Question: Clear storage on logout?
    static let dollarHistoryDirectory = "diningAnalyticsDollarData"
    static let swipeHistoryDirectory = "diningAnalyticsSwipeData"
    @Published var dollarHistory: [DiningAnalyticsBalance] = Storage.fileExists(dollarHistoryDirectory, in: .documents) ? Storage.retrieve(dollarHistoryDirectory, from: .documents, as: [DiningAnalyticsBalance].self) : []
    @Published var swipeHistory: [DiningAnalyticsBalance] = Storage.fileExists(swipeHistoryDirectory, in: .documents) ? Storage.retrieve(swipeHistoryDirectory, from: .documents, as: [DiningAnalyticsBalance].self) : []

    @Published var dollarPredictedZeroDate: Date = Date.endOfSemester
    @Published var predictedDollarSemesterEndBalance: Double = 0
    @Published var predictedDollarZeroPoint: PredictionsGraphView.YXDataPoint = PredictionsGraphView.YXDataPoint(y: 0, x: 0)
    @Published var swipesPredictedZeroDate: Date = Date.endOfSemester
    @Published var predictedSwipesSemesterEndBalance: Double = 0
    @Published var predictedSwipesZeroPoint: PredictionsGraphView.YXDataPoint = PredictionsGraphView.YXDataPoint(y: 0, x: 0)
    @Published var swipeAxisLabel: ([String], [String]) = ([], [])
    @Published var dollarAxisLabel: ([String], [String]) = ([], [])
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
        DiningAPI.instance.getPastDiningBalances(diningToken: diningToken, startDate: startDateStr) { (balances) in
            guard let balances = balances else {
                return
            }
            if startDateStr != self.formatter.string(from: Date()) {
                let newDollarHistory = balances.balanceList.map({DiningAnalyticsBalance(date: self.formatter.date(from: $0.date)!, balance: Double($0.diningDollars) ?? 0.0)})
                let newSwipeHistory = balances.balanceList.map({DiningAnalyticsBalance(date: self.formatter.date(from: $0.date)!, balance: Double($0.regularVisits))})
                self.swipeHistory.append(contentsOf: newSwipeHistory)
                self.dollarHistory.append(contentsOf: newDollarHistory)
                Storage.store(self.swipeHistory, to: .documents, as: DiningAnalyticsViewModel.swipeHistoryDirectory)
                Storage.store(self.dollarHistory, to: .documents, as: DiningAnalyticsViewModel.dollarHistoryDirectory)
            }
            let firstDollarBalance = self.dollarHistory.first!, lastDollarBalance = self.dollarHistory.last!
            self.dollarPredictedZeroDate = self.predictZeroDate(firstBalance: firstDollarBalance, lastBalance: lastDollarBalance)
            self.predictedDollarSemesterEndBalance = self.predictSemesterEndBalance(firstBalance: firstDollarBalance, lastBalance: lastDollarBalance)
            self.dollarAxisLabel = self.getAxisLabelsYX(from: self.dollarHistory)
            self.predictedDollarZeroPoint = PredictionsGraphView.getPredictionZeroPoint(startOfSemester: Date.startOfSemester, endOfSemester: Date.endOfSemester, predictedZeroDate: self.dollarPredictedZeroDate)
            guard let firstSwipeBalance = self.swipeHistory.first, let lastSwipeBalance = self.swipeHistory.last else {
                return
            }
            self.swipesPredictedZeroDate = self.predictZeroDate(firstBalance: firstSwipeBalance, lastBalance: lastSwipeBalance)
            self.predictedSwipesSemesterEndBalance = self.predictSemesterEndBalance(firstBalance: firstSwipeBalance, lastBalance: lastSwipeBalance)
            self.swipeAxisLabel = self.getAxisLabelsYX(from: self.swipeHistory)
            self.predictedSwipesZeroPoint = PredictionsGraphView.getPredictionZeroPoint(startOfSemester: Date.startOfSemester, endOfSemester: Date.endOfSemester, predictedZeroDate: self.swipesPredictedZeroDate)
        }
    }
    func predictZeroDate(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance) -> Date {
        let yIntercept = firstBalance.balance
        let slope = (lastBalance.balance - firstBalance.balance) / Double(Calendar.current.dateComponents([.day], from: firstBalance.date, to: lastBalance.date).day!)
        let offset = -yIntercept / slope
        var dateComponent = DateComponents()
        dateComponent.day = Int(offset)
        return Calendar.current.date(byAdding: dateComponent, to: firstBalance.date)!
    }
    func predictSemesterEndBalance(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance) -> Double {
        // y = slope * x + yIntercept
        let yIntercept = firstBalance.balance
        let slope = (lastBalance.balance - firstBalance.balance) / Double(Calendar.current.dateComponents([.day], from: firstBalance.date, to: lastBalance.date).day!)
        let diffInDays = Calendar.current.dateComponents([.day], from: firstBalance.date, to: Date.endOfSemester).day!
        return ((slope * Double(diffInDays)) + yIntercept)
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
