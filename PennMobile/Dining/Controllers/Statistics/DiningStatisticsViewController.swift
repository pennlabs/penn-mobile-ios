//
//  DiningStatisticsViewController.swift
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
class DiningStatisticsViewController: UIViewController {
    
    private var cancellable: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "example-dining-stats", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try! decoder.decode(DiningStatisticsAPIResponse.self, from: data)
        
        // Create all cards
        let balanceCards = createDiningBalanceHeaders(with: response)
        let statCards = createDiningCards(with: response)
        let cards = balanceCards + statCards
        
        // Create a view with the given cards
        let childView = UIHostingController(rootView: DiningStatisticsView(cards: cards))
        
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    func createDiningBalanceHeaders(with json: DiningStatisticsAPIResponse) -> [DiningStatisticsCard] {
        var balanceCards = [DiningStatisticsCard]()
        
        if let dollarBalance = json.diningDollars {
            balanceCards.append(DiningStatisticsCard(
                DiningBalanceView(description: "Dining Dollars",
                                  image: Image(systemName: "dollarsign.circle.fill"),
                                  balance: dollarBalance,
                                  specifier: "%.2f",
                                  color: .green)))
        }
        
        if let swipesBalance = json.swipes {
            balanceCards.append(DiningStatisticsCard(
                DiningBalanceView(description: "Swipes",
                                  image: Image(systemName: "creditcard.fill"),
                                  balance: Double(swipesBalance),
                                  specifier: "%.f",
                                  color: .blue)))
        }
        
        if let guestSwipesBalance = json.swipes {
            balanceCards.append(DiningStatisticsCard(
                DiningBalanceView(description: "Guest Swipes",
                                  image: Image(systemName: "creditcard.fill"),
                                  balance: Double(guestSwipesBalance),
                                  specifier: "%.f",
                                  color: .purple)))
        }
        
        if balanceCards.count % 2 != 0 {
            balanceCards.append(DiningStatisticsCard(
                BlankDiningBalanceView()))
        }
        
        var stackedBalanceCards = [DiningStatisticsCard]()
        for i in stride(from: 0, to: balanceCards.count, by: 2) {
            stackedBalanceCards.append(DiningStatisticsCard(
                HStack {
                    balanceCards[i].padding(.trailing, 5)
                    balanceCards[i + 1].padding(.leading, 5)
                }
            ))
        }

        return stackedBalanceCards
    }
    
    func createDiningCards(with json: DiningStatisticsAPIResponse) -> [DiningStatisticsCard] {
        var cards = [DiningStatisticsCard]()
        
        if let frequentLocations = json.cards.frequentLocations {
            cards.append(
                DiningStatisticsCard(
                    CardView {
                        FrequentLocationsView(config: frequentLocations)
                    }
                ))
        }
        
        if let recentTransactions = json.cards.recentTransactions {
            cards.append(
                DiningStatisticsCard(
                    CardView {
                        RecentTransactionsView(config: recentTransactions)
                    }
            ))
        }
        
        return cards
    }
}
