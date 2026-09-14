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
    // Nothing here is cached: `refresh()` re-downloads the whole history from the plan
    // start date every time, so a copy on disk would only ever be a stale duplicate.
    @Published public var dollarHistory: [DiningAnalyticsBalance] = []
    @Published public var swipeHistory: [DiningAnalyticsBalance] = []
    @Published public var planStartDate: Date?

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
            // Logged out, or the dining login expired. Don't keep showing numbers
            // that may belong to a previous account.
            self.planStartDate = nil
            self.dollarHistory = []
            self.swipeHistory = []
            return
        }
        
        // We shouldn't just use the dining plan start date as the primary (with no fallback)
        // because RAs don't have dining plans, they just have swipes/dollars added to their account
        let planStartDateResult = await DiningAPI.instance.getDiningPlanStartDate(diningToken: diningToken)
        var planStartDate: Date? = nil
        switch planStartDateResult {
        case .success(let date):
            planStartDate = date
            self.planStartDate = date
        case .failure(let error):
            if case .other = error {
                // We catch "no plan" here, which implies the user previously had a
                // plan but doesn't anymore.
                self.planStartDate = nil
                self.dollarHistory = []
                self.swipeHistory = []
            }
        }
        
        let startDate = planStartDate ?? Date.startOfSemester
        let startDateStr = self.formatter.string(from: startDate)
        
        var dollarBalances: [DiningAnalyticsBalance]?
        var swipesBalances: [DiningAnalyticsBalance]?

        if let balances = try? await DiningAPI.instance.getPastDiningBalances(diningToken: diningToken, startDate: startDateStr).get() {
            dollarBalances = balances.compactMap { el in
                guard let date = self.formatter.date(from: el.date), let balance = Double(el.diningDollars) else { return nil }
                return DiningAnalyticsBalance(date: date, balance: balance)
            }
            swipesBalances = balances.compactMap { el in
                guard let date = self.formatter.date(from: el.date) else { return nil }
                return DiningAnalyticsBalance(date: date, balance: Double(el.regularVisits))
            }
            // If we're able to get the latest balance, remove today's past value and
            // append the current one instead.

            if let current = try? await DiningAPI.instance.getDiningBalance(diningToken: diningToken).get(),
               let currDate = self.formatter.date(from: current.date),
               let dollars = Double(current.diningDollars),
               self.planStartDate != nil { // has a dining plan
                // Append current value in place of the past values that are "today"
                // This makes the graph be real-time accurate
                dollarBalances?.removeAll(where: { Calendar.current.isDate($0.date, inSameDayAs: currDate) })
                swipesBalances?.removeAll(where: { Calendar.current.isDate($0.date, inSameDayAs: currDate) })
                
                dollarBalances?.append(.init(date: currDate, balance: dollars))
                swipesBalances?.append(.init(date: currDate, balance: Double(current.regularVisits)))
            }
        }
        
        // At this point, dollarBalances and swipesBalances hold the past balances from
        // the start of the plan (or of the semester) with the current balance appended,
        // or nil if the fetch failed.

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
        
        guard let first = sorted.first, let last = sorted.last, last.balance <= first.balance else { return nil }
        
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
