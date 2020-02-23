//
//  DiningStatisticsAPIResponse.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct DiningStatisticsAPIResponse: Codable {
    
    let swipes: Int?
    let diningDollars: Double?
    let guestSwipes: Int?
    
    let startOfSemester: Date
    let endOfSemester: Date
    
    let cards: CardData
    
    struct CardData: Codable {
        let recentTransactions: RecentTransactionsCardData?
        let frequentLocations: FrequentLocationsCardData?
        let dailyAverage: DailyAverageCardData?
        
        enum CodingKeys: String, CodingKey {
            case recentTransactions = "recent-transactions"
            case frequentLocations = "frequent-locations"
            case dailyAverage = "daily-average"
        }
        
        struct RecentTransactionsCardData: Codable {
            let type: String
            let headerTitle: String
            let headerBody: String
            let data: [DiningTransaction]
            
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
            
            enum CodingKeys: String, CodingKey {
                case type = "type"
                case headerTitle = "header-title"
                case headerBody = "header-body"
                case data = "data"
            }
        }
        
        struct DailyAverageCardData: Codable {
            let type: String
            let headerTitle: String
            let data: [DailyAverageTuple]
            
            enum CodingKeys: String, CodingKey {
                case type = "type"
                case headerTitle = "header-title"
                case data = "data"
            }
            
            struct DailyAverageTuple: Codable {
                let thisWeek: [DailyAverage]
                let lastWeek: [DailyAverage]
                
                enum CodingKeys: String, CodingKey {
                    case thisWeek = "this-week"
                    case lastWeek = "last-week"
                }
                
                struct DailyAverage: Codable {
                    let date: Date
                    let average: Double
                }
            }
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

struct DiningTransaction: Codable, Hashable {
    let location: String
    let date: Date
    let balance: Double
    let amount: Double
    
    var formattedAmount: String {
        let amountString = String(amount)
        return (self.amount > 0 ? "+" : "") + amountString
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a EEEE, MMM d"
        return formatter.string(from: self.date)
    }
}

struct FrequentLocation: Codable {
    let location: String
    let week: Double
    let month: Double
    let semester: Double
}
