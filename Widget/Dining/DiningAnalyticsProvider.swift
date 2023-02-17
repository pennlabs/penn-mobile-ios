//
//  DiningAnalyticsProvider.swift
//  PennMobile
//
//  Created by Anthony Li on 11/5/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import Intents

struct BalanceDetails<Balance: AdditiveArithmetic & Comparable> {
    var remaining: Balance
    var total: Balance
    var projectedEnd: Balance
    var projectedEndDate: Date?

    var used: Balance {
        max(.zero, total - remaining)
    }
}

struct DiningAnalyticsEntry<Configuration>: TimelineEntry {
    let date: Date
    let configuration: Configuration

    let swipes: BalanceDetails<Int>?
    let dollars: BalanceDetails<Double>?
}

private var cachedSwipes: BalanceDetails<Int>?
private var cachedDollars: BalanceDetails<Double>?
private var lastFetchDate: Date?
private var refreshTask: Task<Void, Never>?
private let cacheAge: TimeInterval = 15 * 60

private enum DiningAnalyticsProviderError: Error {
    case noDiningToken
}

private func refresh() async {
    let model = DiningAnalyticsViewModel()
    let modelRefreshTask = Task {
        await model.refresh()
    }

    let balancesTask = Task {
        do {
            guard let diningToken = KeychainAccessible.instance.getDiningToken() else {
                throw DiningAnalyticsProviderError.noDiningToken
            }
            
            let balances = try await Optional(DiningAPI.instance.getDiningBalance(diningToken: diningToken).get())
            try? Storage.storeThrowing(balances, to: .groupCaches, as: DiningBalance.directory)
            return balances
        } catch let error {
            print("Couldn't fetch dining balances: \(error)")
            return try? Storage.retrieveThrowing(DiningBalance.directory, from: .groupCaches, as: DiningBalance.self)
        }
    }

    await modelRefreshTask.value
    guard let balances = await balancesTask.value else {
        return
    }

    let remainingSwipes = balances.regularVisits
    let totalSwipes = max(remainingSwipes, model.swipeHistory.max().map { Int($0.balance) } ?? 0)
    let projectedSwipes = Int(model.predictedSwipesSemesterEndBalance)
    cachedSwipes = BalanceDetails(remaining: remainingSwipes, total: totalSwipes, projectedEnd: projectedSwipes)
    if projectedSwipes <= 0 {
        cachedSwipes?.projectedEndDate = model.swipesPredictedZeroDate
    }

    guard let remainingDollars = Double(balances.diningDollars) else {
        return
    }
    let totalDollars = max(remainingDollars, model.dollarHistory.max()?.balance ?? 0)
    let projectedDollars = model.predictedDollarSemesterEndBalance
    cachedDollars = BalanceDetails(remaining: remainingDollars, total: totalDollars, projectedEnd: projectedDollars)
    if projectedDollars <= 0 {
        cachedDollars?.projectedEndDate = model.dollarPredictedZeroDate
    }
}

private func snapshot<Configuration>(configuration: Configuration) async -> DiningAnalyticsEntry<Configuration> {
    if refreshTask == nil || (lastFetchDate != nil && Date().timeIntervalSince(lastFetchDate!) > cacheAge) {
        refreshTask = Task {
            lastFetchDate = Date()
            await refresh()
        }
    }

    await refreshTask!.value

    return DiningAnalyticsEntry(date: Date(), configuration: configuration, swipes: cachedSwipes, dollars: cachedDollars)
}

private func timeline<Configuration>(configuration: Configuration) async -> Timeline<DiningAnalyticsEntry<Configuration>> {
    await Timeline(entries: [snapshot(configuration: configuration)], policy: .after(Calendar.current.date(byAdding: .hour, value: 2, to: Date())!))
}

struct IntentDiningAnalyticsProvider<Intent: INIntent & ConfigurationRepresenting>: IntentTimelineProvider {
    let placeholderConfiguration: Intent.Configuration

    func getSnapshot(for intent: Intent, in context: Context, completion: @escaping (DiningAnalyticsEntry<Intent.Configuration>) -> Void) {
        Task {
            completion(await snapshot(configuration: intent.configuration))
        }
    }

    func getTimeline(for intent: Intent, in context: Context, completion: @escaping (Timeline<DiningAnalyticsEntry<Intent.Configuration>>) -> Void) {
        Task {
            completion(await timeline(configuration: intent.configuration))
        }
    }

    func placeholder(in context: Context) -> DiningAnalyticsEntry<Intent.Configuration> {
        DiningAnalyticsEntry(date: Date(), configuration: placeholderConfiguration, swipes: cachedSwipes, dollars: cachedDollars)
    }
}
