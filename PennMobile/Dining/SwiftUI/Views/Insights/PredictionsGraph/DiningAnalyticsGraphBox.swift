//
//  DiningAnalyticsGraphBox.swift
//  PennMobile
//
//  Created by Jordan H on 1/30/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GraphView: View {
    enum BalanceType {
        case swipes
        case dollars
    }
    let type: BalanceType
    let data: [DiningAnalyticsBalance]
    let start: Date
    let end: Date = Date.endOfSemester
    
    let prediction: DiningAnalyticsPredictionResult
    
    var color: Color {
        type == .swipes ? .blue : .green
    }
    var balanceFormat: String {
        type == .swipes ? "%.0f Swipes" : "$%.2f"
    }
    var helpText: String {
        switch prediction {
        case .willHaveExtra(let amount, let slope):
            return "Based on your past behavior, we project you'll end the semester with \(type == .swipes ? "swipes" : "dollars") to spare."
        case .willRunOut(let date, let slope):
            return "Based on your current balance and past behavior, we project you'll run out on this date."
        }
    }
    var formattedZeroDate: String? {
        guard case let .willRunOut(date, _) = prediction else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d"
        return formatter.string(from: date)
    }
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                CardHeaderTitleView(color: color, icon: .predictions, title: "\(type == .swipes ? "Swipes" : "Dining Dollars") Predictions")
            }
            Divider()
                .padding([.top, .bottom])
            AnalyticsGraph(data: data, color: color, start: start, end: end, prediction: prediction, balanceFormat: balanceFormat)
            Divider()
                .padding([.top, .bottom])
            HStack {
                VStack(alignment: .leading) {
                    switch prediction {
                    case .willHaveExtra(let amount, _):
                        Text("Extra Balance")
                            .font(.caption)
                        Text(String(format: balanceFormat, amount))
                            .font(Font.system(size: 21, weight: .bold, design: .rounded))
                    case .willRunOut(let date, _):
                        if let formattedZeroDate { // this should never be false but unwrapping here for stability
                            Text("Out of \(type == .swipes ? "Swipes" : "Dollars")")
                                .font(.caption)
                            Text(formattedZeroDate)
                                .font(Font.system(size: 21, weight: .bold, design: .rounded))
                        }
                    }
                    Spacer()
                }
                .padding(.trailing)
                VStack {
                    Text(helpText)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }.frame(height: 60)
        }
        .padding()
    }
}
