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

public struct DiningAnalyticsBalance: Codable, Equatable, Identifiable {
    public let date: Date
    public let balance: Double
    public var id: Date {date}
    
    public init(date: Date, balance: Double) {
        self.date = date
        self.balance = balance
    }
}

extension DiningAnalyticsBalance: Comparable {
    public static func <(lhs: DiningAnalyticsBalance, rhs: DiningAnalyticsBalance) -> Bool {
        if lhs.balance < rhs.balance {
            return true
        } else if lhs.balance > rhs.balance {
            return false
        } else {
            return lhs.date < rhs.date
        }
    }
}

public class DiningAnalyticsViewModel: ObservableObject {
    public static let dollarHistoryDirectory = "diningAnalyticsDollarData"
    public static let swipeHistoryDirectory = "diningAnalyticsSwipeData"
    public static let planStartDateDirectory = "diningAnalyticsPlanStartDate"
    @Published public var dollarHistory: [DiningAnalyticsBalance] = Storage.fileExists(dollarHistoryDirectory, in: .groupDocuments) ? Storage.retrieve(dollarHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self) : []
    @Published public var swipeHistory: [DiningAnalyticsBalance] = Storage.fileExists(swipeHistoryDirectory, in: .groupDocuments) ? Storage.retrieve(swipeHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self) : []
    @Published public var planStartDate: Date? = try? Storage.retrieveThrowing(planStartDateDirectory, from: .groupDocuments, as: Date.self)
    @Published public var dollarPredictedZeroDate: Date = Date.endOfSemester
    @Published public var predictedDollarSemesterEndBalance: Double = 0
    @Published public var swipesPredictedZeroDate: Date = Date.endOfSemester
    @Published public var predictedSwipesSemesterEndBalance: Double = 0
    @Published public var swipeAxisLabel: ([String], [String]) = ([], [])
    @Published public var dollarAxisLabel: ([String], [String]) = ([], [])
    @Published public var dollarSlope: Double = 0.0
    @Published public var swipeSlope: Double = 0.0
    @Published public var shouldRemoveOutliers: Bool = true {
        didSet {
            Task {
                await refresh()
            }
        }
    }
    
    @Published public var selectedOptionIndex = 0 {
        didSet {
            populateAxesAndPredictions()
        }
    }

    var yIntercept = 0.0
    var slope = 0.0
    let formatter = DateFormatter()

    public init() {
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
    
    public func refresh(refreshWidgets: Bool = false) async {
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
        if (shouldRemoveOutliers) {
            removeOutliers()
        }
        filterData()
        
        let last7dollarHistory: [DiningAnalyticsBalance] = dollarHistory.suffix(7)
        let last7swipeHistory: [DiningAnalyticsBalance] = swipeHistory.suffix(7)
        
        guard let lastDollarBalance = self.dollarHistory.last,
              let lastSwipeBalance = self.swipeHistory.last else {
            return
        }
        guard let last7maxDollarBalance = (last7dollarHistory.max { $0.balance < $1.balance }),
              let last7maxSwipeBalance = (last7swipeHistory.max { $0.balance < $1.balance }),
              let maxDollarBalance = (self.dollarHistory.max { $0.balance < $1.balance }),
              let maxSwipeBalance = (self.swipeHistory.max { $0.balance < $1.balance }) else {
            return
        }
        
        // If no dining plan found, refresh will return, these are just placeholders
        var startDollarBalance = maxDollarBalance
        var startSwipeBalance = maxSwipeBalance
        var last7startDollarBalance = last7maxDollarBalance
        var last7startSwipeBalance = last7maxSwipeBalance
        guard let planStartDate else { return }

        // If dining plan found, start prediction from the date dining plan started
        last7startDollarBalance = (last7dollarHistory.first { $0.date == planStartDate }) ?? last7startDollarBalance
        last7startSwipeBalance = (last7swipeHistory.first { $0.date == planStartDate }) ?? last7startSwipeBalance
        startDollarBalance = (self.dollarHistory.first { $0.date == planStartDate }) ?? startDollarBalance
        startSwipeBalance = (self.swipeHistory.first { $0.date == planStartDate }) ?? startSwipeBalance
        // However, it's possible that people recharged dining dollars (swipes maybe?), and if so, predict from this date (most recent increase)
        for (i, day) in self.dollarHistory.enumerated() {
            if i != 0 && day.date > planStartDate && day.balance > self.dollarHistory[i - 1].balance {
                startDollarBalance = day
                if (day.date > last7startDollarBalance.date) {
                    last7startDollarBalance = day
                }
            }
        }
        for (i, day) in self.swipeHistory.enumerated() {
            if i != 0 && day.date > planStartDate && day.balance > self.swipeHistory[i - 1].balance {
                startSwipeBalance = day
                if (day.date > last7startDollarBalance.date) {
                    last7startSwipeBalance = day
                }
            }
        }

        // Get dollar predictions using data from all dates and dollar predictions using data for the appropriate calculation
        var selectedDollarSlope = 0.0
        var selectedSwipeSlope = 0.0
        if selectedOptionIndex == 0 {
            (selectedDollarSlope, _) = self.getSlopeAndWeight(firstBalance: startDollarBalance, lastBalance: lastDollarBalance)
            (selectedSwipeSlope, _) = self.getSlopeAndWeight(firstBalance: startSwipeBalance, lastBalance: lastSwipeBalance)
        } else if selectedOptionIndex == 1 {
            let (allDollarSlope, _) = self.getSlopeAndWeight(firstBalance: startDollarBalance, lastBalance: lastDollarBalance)
            let (last7DollarSlope, _) = self.getSlopeAndWeight(firstBalance: last7startDollarBalance, lastBalance: lastDollarBalance)
            selectedDollarSlope = (allDollarSlope + last7DollarSlope) / 2.0
            
            let (allSwipeSlope, _) = self.getSlopeAndWeight(firstBalance: startSwipeBalance, lastBalance: lastSwipeBalance)
            let (last7SwipeSlope, _) = self.getSlopeAndWeight(firstBalance: last7startSwipeBalance, lastBalance: lastSwipeBalance)
            selectedSwipeSlope = (allSwipeSlope + last7SwipeSlope) / 2.0
        } else if selectedOptionIndex == 2 {
            selectedDollarSlope = getWeightedAverageSlope(allBalance: self.dollarHistory)
            selectedSwipeSlope = getWeightedAverageSlope(allBalance: self.swipeHistory)
        }
        
        let dollarPredictions = self.getPredictions(firstBalance: lastDollarBalance, slope: selectedDollarSlope, maxBalance: maxDollarBalance)
        self.dollarSlope = dollarPredictions.slope
        self.dollarPredictedZeroDate = dollarPredictions.predictedZeroDate
        self.predictedDollarSemesterEndBalance = dollarPredictions.predictedEndBalance
        
        let swipePredictions = self.getPredictions(firstBalance: lastSwipeBalance, slope: selectedSwipeSlope, maxBalance: maxSwipeBalance)
        self.swipeSlope = swipePredictions.slope
        self.swipesPredictedZeroDate = swipePredictions.predictedZeroDate
        self.predictedSwipesSemesterEndBalance = swipePredictions.predictedEndBalance
        
        self.dollarAxisLabel = self.getAxisLabelsYX(from: self.dollarHistory)
        self.swipeAxisLabel = self.getAxisLabelsYX(from: self.swipeHistory)
    }
    
    func removeOutliers() {
        let dollarStdDev = standardDeviation(arr:self.dollarHistory.map({$0.balance}))
        let dollarJumpIndex = self.dollarHistory.firstIndex(where: { $0.balance <= -1.5 * dollarStdDev || $0.balance >= 1.5 * dollarStdDev})
        self.dollarHistory.removeFirst(dollarJumpIndex ?? 0)
        
        let swipeStdDev = standardDeviation(arr:self.swipeHistory.map({$0.balance}))
        let swipeJumpIndex = self.swipeHistory.firstIndex(where: { $0.balance <= -1.5 * swipeStdDev || $0.balance >= 1.5 * swipeStdDev})
        self.swipeHistory.removeFirst(swipeJumpIndex ?? 0)
    }
    
    func getWeightedAverageSlope(allBalance: [DiningAnalyticsBalance]) -> Double {
        var totalWeightedSlope = 0.0
        var totalWeight = 0.0

        for i in 1..<allBalance.count {
            let (slope, weight) = getSlopeAndWeight(firstBalance: allBalance[i - 1], lastBalance: allBalance[i])
            totalWeightedSlope += slope * weight
            totalWeight += weight
        }

        let averageSlope = totalWeight > 0 ? totalWeightedSlope / totalWeight : totalWeightedSlope
        return averageSlope
    }
    
    func filterData() {
        if self.dollarHistory.count >= 2 {
            self.dollarHistory = self.dollarHistory.enumerated().filter { index, dollar in
                guard index > 0 && index < self.dollarHistory.count - 1 else {
                    return true
                }
                let previousBalance = self.dollarHistory[index - 1].balance
                let nextBalance = self.dollarHistory[index + 1].balance
                
                //include if we a) have a dollar balance, b) the previous day is > 0, c)
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
    
    func getPredictions(firstBalance: DiningAnalyticsBalance, slope: Double, maxBalance: DiningAnalyticsBalance) -> (slope: Double, predictedZeroDate: Date, predictedEndBalance: Double) {
        if slope == 0.0 || abs(slope) == Double.infinity {
            let zeroDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.endOfSemester)!
            return (Double(0.0), zeroDate, firstBalance.balance)
        } else {
            // This is the slope needed to calculate zeroDate and endBalance
            let zeroDate = self.predictZeroDate(firstBalance: firstBalance, slope: slope)
            let endBalance = self.predictSemesterEndBalance(firstBalance: firstBalance, slope: slope)
            let fullSemester = Date.startOfSemester.distance(to: Date.endOfSemester)
            let fullZeroDistance = firstBalance.date.distance(to: zeroDate)
            let deltaX = fullZeroDistance / fullSemester
            let deltaY = firstBalance.balance / maxBalance.balance
            let graphSlope = -deltaY / deltaX // Resetting slope to different value for graph format
            return (graphSlope, zeroDate, endBalance)
        }
    }
    
    func getSlopeAndWeight(firstBalance: DiningAnalyticsBalance, lastBalance: DiningAnalyticsBalance) -> (slope: Double, weight: Double) {
        if firstBalance.date == lastBalance.date || firstBalance.balance == lastBalance.balance {
            return (Double(0.0), 1)
        }
        let balanceDiff = lastBalance.balance - firstBalance.balance
        let timeDiff = Double(Calendar.current.dateComponents([.day], from: firstBalance.date, to: lastBalance.date).day!)
        let weight = balanceDiff > 0 ? 0 : (timeDiff > 0 ? timeDiff : 1) // Days as weight
        let slope = balanceDiff / timeDiff
        return (slope, weight)
    }
    
    func predictZeroDate(firstBalance: DiningAnalyticsBalance, slope: Double) -> Date {
        let offset = -firstBalance.balance / slope
        return slope == 0 ? Date.distantFuture : Calendar.current.date(byAdding: .day, value: Int(offset), to: firstBalance.date)!
    }
    
    func predictSemesterEndBalance(firstBalance: DiningAnalyticsBalance, slope: Double) -> Double {
        let diffInDays = Calendar.current.dateComponents([.day], from: firstBalance.date, to: Date.endOfSemester).day!
        let endBalance = (slope * Double(diffInDays)) + firstBalance.balance
        return endBalance
    }
    
    func standardDeviation(arr:[Double]) -> Double{
       let size = arr.count
        var sum = 0.0
       var SD = 0.0
       var S = 0.0
       var resultSD = 0.0
       
       // Calculating the mean
       for x in 0..<size{
          sum += arr[x]
       }
       let meanValue = sum/Double(size)
       
       // Calculating standard deviation
       for y in 0..<size{
          SD += pow(Double(arr[y] - meanValue), 2)
       }
       S = SD/Double(size)
       resultSD = sqrt(S)
       
       return resultSD
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
