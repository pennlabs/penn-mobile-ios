//
//  DiningStatisticsAPIResponse.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct DiningStatisticsAPIResponse: Codable {
    
    let swipes: Int
    let diningDollars: Double
    let guestSwipes: Int
    
    let startOfSemester: Date
    let endOfSemester: Date
    
    let cards: CardData
    
    struct CardData: Codable {
        let recentTransactions: RecentTransactionsCardData?
        let frequentLocations: FrequentLocationsCardData?
        
        struct RecentTransactionsCardData: Codable {
            let type: String
            let headerTitle: String
            let headerBody: String
            let data: [DiningTransaction]
            
            struct DiningTransaction: Codable {
                let location: String
                let date: Date
                let balance: Double
                let amount: Double
            }
            
            enum CodingKeys: String, CodingKey {
                case type = "type"
                case headerTitle = "header-title"
                case headerBody = "header-body"
                case data = "data"
            }
        }
        
        struct FrequentLocationsCardData: Codable {
            let type: String
            let headerTitle: String
            let headerBody: String
            let data: [FrequentLocation]
            
            struct FrequentLocation: Codable {
                let location: String
                let week: Double
                let month: Double
                let semester: Double
            }
            
            enum CodingKeys: String, CodingKey {
                case type = "type"
                case headerTitle = "header-title"
                case headerBody = "header-body"
                case data = "data"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case recentTransactions = "recent-transactions"
            case frequentLocations = "frequent-locations"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case swipes = "swipes"
        case diningDollars = "dining-dollars"
        case guestSwipes = "guest-swipes"
        case startOfSemester = "start-of-semester"
        case endOfSemester = "end-of-semester"
        case cards = "cards"
    }
}
