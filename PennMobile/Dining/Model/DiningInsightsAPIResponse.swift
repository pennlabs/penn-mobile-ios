//
//  DiningInsightsAPIResponse.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

// MARK: Full API Response
struct DiningInsightsAPIResponse: Codable {

    static let directory = "diningInsights.json"

    let swipes: Int?
    let diningDollars: Double?
    let guestSwipes: Int?

    let startOfSemester: Date
    let endOfSemester: Date

    let cards: CardData

    struct CardData: Codable {
        // These cards are defined in extensions of CardData to keep this struct definition small
        let recentTransactions: RecentTransactionsCardData?
        let frequentLocations: FrequentLocationsCardData?
        let dailyAverage: DailyAverageCardData?
        let predictionsGraphSwipes: PredictionsGraphCardData?
        let predictionsGraphDollars: PredictionsGraphCardData?

        enum CodingKeys: String, CodingKey {
            case recentTransactions = "recent-transactions"
            case frequentLocations = "frequent-locations"
            case dailyAverage = "daily-average"
            case predictionsGraphSwipes = "predictions-graph-swipes"
            case predictionsGraphDollars = "predictions-graph-dollars"
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

// MARK: Dining Transaction
struct DiningTransaction: Codable, Hashable {
    let location: String
    let date: Date
    let balance: Double
    let amount: Double

    var formattedAmount: String {
        let amountString = String(format: "%.2f", amount)
        return (self.amount > 0 ? "+" : "") + amountString
    }

    var formattedBalance: String {
        return String(format: "%.2f", balance)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a EEEE, MMM d"
        return formatter.string(from: self.date)
    }
}

// MARK: Frequent Location
struct FrequentLocation: Codable {
    let location: String
    let week: Double
    let month: Double
    let semester: Double
}

// MARK: Recent Transactions Card
extension DiningInsightsAPIResponse.CardData {
    struct RecentTransactionsCardData: Codable {
        let type: String
        let data: [DiningTransaction]
    }
}

// MARK: Frequent Locations Card
extension DiningInsightsAPIResponse.CardData {
    struct FrequentLocationsCardData: Codable {
        let type: String
        let data: [FrequentLocation]
    }
}

// MARK: Predictions Graph Card
extension DiningInsightsAPIResponse.CardData {
    struct PredictionsGraphCardData: Codable {
        let type: String
        let data: [DiningBalance]
        let startOfSemester: Date
        let endOfSemester: Date
        let predictedZeroDate: Date
        let semesterEndBalance: Double?

        enum CodingKeys: String, CodingKey {
            case type = "type"
            case data = "data"
            case startOfSemester = "start-of-semester"
            case endOfSemester = "end-of-semester"
            case predictedZeroDate = "predicted-zero-date"
            case semesterEndBalance = "balance-at-semester-end"
        }

        struct DiningBalance: Codable {
            let date: Date
            let balance: Double
        }

        enum BalanceType: String {
            case dollars
            case swipes
        }
    }
}

// MARK: Daily Average Card
extension DiningInsightsAPIResponse.CardData {
    struct DailyAverageCardData: Codable {
        let type: String
        let data: DailyAverageTuple

        struct DailyAverageTuple: Codable {
            let thisWeek: [DailyAverage]
            let lastWeek: [DailyAverage]

            enum CodingKeys: String, CodingKey {
                case thisWeek = "this-week"
                case lastWeek = "last-week"
            }

            struct DailyAverage: Codable, Comparable {
                let date: Date
                let average: Double

                static func < (lhs: DiningInsightsAPIResponse.CardData.DailyAverageCardData.DailyAverageTuple.DailyAverage, rhs: DiningInsightsAPIResponse.CardData.DailyAverageCardData.DailyAverageTuple.DailyAverage) -> Bool {
                    return lhs.average < rhs.average
                }
            }
        }
    }
}
