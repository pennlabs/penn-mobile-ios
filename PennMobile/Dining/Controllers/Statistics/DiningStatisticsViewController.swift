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
        
        let delegate = PrivacyPermissionDelegate()
        self.cancellable = delegate.objectDidChange.sink { (delegate) in
            if let decision = delegate.userDecision {
                switch decision {
                case .affirmative:
                    UserDefaults.standard.setLastDidAskPermission(for: .anonymizedCourseSchedule)
                    UserDefaults.standard.set(.anonymizedCourseSchedule, to: true)
                    UserDBManager.shared.saveUserPrivacySettings()
                    //self.fetchAndSaveCourses()
                case .negative:
                    UserDefaults.standard.setLastDidAskPermission(for: .anonymizedCourseSchedule)
                    //self.declinePermission()
                    self.dismiss(animated: true, completion: nil)
                case .moreInfo:
                    print("nothing")
                }
            }
        }
        
        let path = Bundle.main.path(forResource: "example-dining-stats", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try! decoder.decode(DiningStatisticsAPIResponse.self, from: data)
        
        dump(response)
        
        let balanceHeaders: [DiningStatisticsCard] = [
            DiningStatisticsCard(CardView { DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "dollarsign.circle.fill"), balance: 427.84, specifier: "%.2f") }),
            DiningStatisticsCard(CardView { DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "dollarsign.circle.fill"), balance: 427.84, specifier: "%.2f") })
        ]
        
        /*let cards: [DiningStatisticsCard] = [
            DiningStatisticsCard(Text("Hello World")),
            DiningStatisticsCard(Group{ Text("Hello darkness") }),
            DiningStatisticsCard(CardView { DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "dollarsign.circle.fill"), balance: 427.84, specifier: "%.2f") }),
            DiningStatisticsCard(CardView { DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "dollarsign.circle.fill"), balance: 427.84, specifier: "%.2f") }),
            DiningStatisticsCard(CardView { DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "gamecontroller.fill"), balance: 427.84, specifier: "%.2f") })
        ]*/
        
        let cards = createDiningCards(with: response)
        let childView = UIHostingController(rootView: DiningStatisticsView(cards: cards))
        
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    func createDiningHeaders() -> [DiningStatisticsCard] {
        return []
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
