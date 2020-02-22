//
//  DiningStatisticsResponse.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct DiningStatisticsAPIResponse {
    
    let swipes: Int
    let diningDollars: Double
    let guestSwipes: Int
    
    let startOfSemester: Date
    let endOfSemester: Date
    
    let cards: CardData
    
    struct CardData {
        let recentTransactions: RecentTransactions?
        let frequentLocations: FrequentLocations?
        
        struct RecentTransactions: Codable {
            let type: String
            let headerTitle: String
            let headerBody: String
            let data: [DiningTransaction]
        }
        
        struct FrequentLocations: Codable {
            let type: String
            let headerTitle: String
            let headerBody: String
            let data: [DiningTransaction]
        }
    }
}

struct DiningTransaction: Codable {
    let location: String
    let date: Date
    let balance: Double
    let amount: Double
}
