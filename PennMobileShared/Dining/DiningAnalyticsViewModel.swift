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

public enum DiningAnalyticsPredictionResult {
    case willHaveExtra(amount: Double, slope: Double)
    case willRunOut(date: Date, slope: Double)
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

@MainActor
public class DiningAnalyticsViewModel: ObservableObject {
    nonisolated public static let dollarHistoryDirectory = "diningAnalyticsDollarData"
    nonisolated public static let swipeHistoryDirectory = "diningAnalyticsSwipeData"
    nonisolated public static let planStartDateDirectory = "diningAnalyticsPlanStartDate"
    @Published public var dollarHistory: [DiningAnalyticsBalance] = Storage.fileExists(dollarHistoryDirectory, in: .groupDocuments) ? Storage.retrieve(dollarHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self) : []
    @Published public var swipeHistory: [DiningAnalyticsBalance] = Storage.fileExists(swipeHistoryDirectory, in: .groupDocuments) ? Storage.retrieve(swipeHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self) : []
    @Published public var planStartDate: Date? = try? Storage.retrieveThrowing(planStartDateDirectory, from: .groupDocuments, as: Date.self)
    
    public var dollarPrediction: DiningAnalyticsPredictionResult? {
        // We should take a subset starting at the latest increase in value. (in the event that the user adds more swipes or something)
        let sorted = dollarHistory.sorted { $0.date < $1.date }

        let lastIncreaseIndex = sorted.indices.dropFirst().last {
            sorted[$0].balance > sorted[$0 - 1].balance
        } ?? sorted.startIndex

        return predict(on: Array(sorted[lastIncreaseIndex...]))
    }
    
    public var swipesPrediction: DiningAnalyticsPredictionResult? {
        let sorted = swipeHistory.sorted { $0.date < $1.date }

        let lastIncreaseIndex = sorted.indices.dropFirst().last {
            sorted[$0].balance > sorted[$0 - 1].balance
        } ?? sorted.startIndex

        return predict(on: Array(sorted[lastIncreaseIndex...]))
    }
    
    let formatter: DateFormatter = {
        let form = DateFormatter()
        form.dateFormat = "yyyy-MM-dd"
        return form
    }()
    
    public init() {}
    
    public func refresh(refreshWidgets: Bool = false) async {
        guard let diningToken = KeychainAccessible.instance.getDiningToken() else {
            return
        }
        
        // We shouldn't just use the dining plan start date as the primary (with no fallback)
        // because RAs don't have dining plans, they just have swipes/dollars added to their account
        let planStartDate: Date? = try? await DiningAPI.instance.getDiningPlanStartDate(diningToken: diningToken).get()
        if let planStartDate {
            try? Storage.storeThrowing(planStartDate, to: .groupDocuments, as: Self.planStartDateDirectory)
        }
        let startDate = planStartDate ?? Date.startOfSemester
        let startDateStr = self.formatter.string(from: startDate)
        
        var dollarBalances = try? Storage.retrieveThrowing(DiningAnalyticsViewModel.dollarHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self)
        var swipesBalances = try? Storage.retrieveThrowing(DiningAnalyticsViewModel.swipeHistoryDirectory, from: .groupDocuments, as: [DiningAnalyticsBalance].self)
        
        if let balances = try? await DiningAPI.instance.getPastDiningBalances(diningToken: diningToken, startDate: startDateStr).get() {
            dollarBalances = balances.compactMap { el in
                guard let date = self.formatter.date(from: el.date), let balance = Double(el.diningDollars) else { return nil }
                return DiningAnalyticsBalance(date: date, balance: balance)
            }
            swipesBalances = balances.compactMap { el in
                guard let date = self.formatter.date(from: el.date) else { return nil }
                return DiningAnalyticsBalance(date: date, balance: Double(el.regularVisits))
            }
            // If we're able to get latest balances, remove today and append current balance
            // Save to storage
            // Otherwise just get from storage and append current value
            
            if let current = try? await DiningAPI.instance.getDiningBalance(diningToken: diningToken).get(),
               let currDate = self.formatter.date(from: current.date),
               let dollars = Double(current.diningDollars) {
                // Append current value in place of the past values that are "today"
                // This makes the graph be real-time accurate
                dollarBalances?.removeAll(where: { Calendar.current.isDate($0.date, inSameDayAs: currDate) })
                swipesBalances?.removeAll(where: { Calendar.current.isDate($0.date, inSameDayAs: currDate) })
                
                dollarBalances?.append(.init(date: currDate, balance: dollars))
                swipesBalances?.append(.init(date: currDate, balance: Double(current.regularVisits)))
            }
        }
        
        // At this point, dollarBalances and swipesBalances is EITHER:
        // (1) The past balances from the start of their plan or the start of the semester, with the current balance appended to the end
        // (2) The previously stored balances.
        
        if let dollarBalances, let swipesBalances {
            try? Storage.storeThrowing(dollarBalances, to: .groupDocuments, as: Self.dollarHistoryDirectory)
            try? Storage.storeThrowing(swipesBalances, to: .groupDocuments, as: Self.swipeHistoryDirectory)
        }
        
        // @Khoi this silently fails if something went wrong, we should probably handle this differently
        self.dollarHistory = dollarBalances ?? []
        self.swipeHistory = swipesBalances ?? []
        
        
        if refreshWidgets {
            WidgetKind.diningAnalyticsWidgets.forEach {
                WidgetCenter.shared.reloadTimelines(ofKind: $0)
            }
        }
    }
    
    func predict(on balances: [DiningAnalyticsBalance]) -> DiningAnalyticsPredictionResult? {
        // Sort by date.
        let sorted = balances.sorted(by: {
            $0.date < $1.date
        })
        
        guard let first = sorted.first, let last = sorted.last, last.balance < first.balance else { return nil }
        
        let deltaY = last.balance - first.balance
        let deltaX = last.date.timeIntervalSince1970 - first.date.timeIntervalSince1970
        let slope = deltaY / deltaX
        
        let runOutDateTS: TimeInterval = (-1 * first.balance) / slope + first.date.timeIntervalSince1970
        let runOutDate = Date(timeIntervalSince1970: runOutDateTS)
        // check if runOutDate < Date.endOfSemester
        if case .orderedAscending = Calendar.current.compare(runOutDate, to: Date.endOfSemester, toGranularity: .day) {
            return .willRunOut(date: runOutDate, slope: slope)
        }
        
        let extra = slope * (Date.endOfSemester.timeIntervalSince1970 - first.date.timeIntervalSince1970) + first.balance
        return .willHaveExtra(amount: extra, slope: slope)
    }
}
