//
//  DiningInsightsViewController.swift
//  PennMobile
//
//  Created by Elizabeth Powell on 2/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
class DiningInsightsViewController: UIViewController {
    
    private var cancellable: Any?
    private var diningInsights: DiningInsightsAPIResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DiningAPI.instance.fetchDiningInsights { (result) in
            if let diningInsights = try? result.get() {
                self.diningInsights = diningInsights
                DiningDataStore.shared.saveInsightToCache(diningInsights)
            } else {
                // Need to retrieve from cache
            }
        }
        
        let path = Bundle.main.path(forResource: "example-dining-stats", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        diningInsights = try! decoder.decode(DiningInsightsAPIResponse.self, from: data)
        
        // Create all cards
        let balanceCards = createDiningBalanceHeaders(with: diningInsights)
        let statCards = createDiningCards(with: diningInsights)
        let cards = balanceCards + statCards
        
        // Create a view with the given cards
        let childView = UIHostingController(rootView: DiningInsightsView(cards: cards))
        
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    private func createDiningBalanceHeaders(with json: DiningInsightsAPIResponse) -> [DiningInsightCard] {
        var balanceCards = [DiningInsightCard]()
        
        if let dollarBalance = json.diningDollars {
            balanceCards.append(DiningInsightCard(
                DiningBalanceView(description: "Dining Dollars",
                                  image: Image(systemName: "dollarsign.circle.fill"),
                                  balance: dollarBalance,
                                  specifier: "%.2f",
                                  color: .green)))
        }
        
        if let swipesBalance = json.swipes {
            balanceCards.append(DiningInsightCard(
                DiningBalanceView(description: "Swipes",
                                  image: Image(systemName: "creditcard.fill"),
                                  balance: Double(swipesBalance),
                                  specifier: "%g",
                                  color: .blue)))
        }
        
        if let guestSwipesBalance = json.guestSwipes {
            balanceCards.append(DiningInsightCard(
                DiningBalanceView(description: "Guest Swipes",
                                  image: Image(systemName: "creditcard.fill"),
                                  balance: Double(guestSwipesBalance),
                                  specifier: "%g",
                                  color: .purple)))
        }
        
        if balanceCards.count % 2 != 0 {
            balanceCards.append(DiningInsightCard(
                BlankDiningBalanceView()))
        }
        
        var stackedBalanceCards = [DiningInsightCard]()
        for i in stride(from: 0, to: balanceCards.count, by: 2) {
            stackedBalanceCards.append(DiningInsightCard(
                HStack {
                    balanceCards[i].padding(.trailing, 5)
                    balanceCards[i + 1].padding(.leading, 5)
                }
            ))
        }

        return stackedBalanceCards
    }
    
    private func createDiningCards(with json: DiningInsightsAPIResponse) -> [DiningInsightCard] {
        var cards = [DiningInsightCard]()
        
        if let config = json.cards.predictionsGraphSwipes {
            cards.append(
                DiningInsightCard(
                    CardView {
                        PredictionsGraphView(config: config)
                    }
                ))
        }
        
        if let config = json.cards.predictionsGraphDollars {
            cards.append(
                DiningInsightCard(
                    CardView {
                        PredictionsGraphView(config: config)
                    }
                ))
        }
        
        if let config = json.cards.frequentLocations {
            cards.append(
                DiningInsightCard(
                    CardView {
                        FrequentLocationsView(config: config)
                    }
                ))
        }
        
        if let config = json.cards.recentTransactions {
            cards.append(
                DiningInsightCard(
                    CardView {
                        RecentTransactionsView(config: config)
                    }
            ))
        }
        
        if let config = json.cards.dailyAverage {
            cards.append(
                DiningInsightCard(
                    CardView {
                        DailyAverageView(config: config)
                    }
            ))
        }
        
        return cards
    }
}
