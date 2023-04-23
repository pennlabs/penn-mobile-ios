//
//  DiningAnalyticsGraphBox.swift
//  PennMobile
//
//  Created by Jordan H on 1/30/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct GraphView: View {
    enum BalanceType {
        case swipes
        case dollars
    }
    var type: BalanceType
    @Binding var data: [DiningAnalyticsBalance]
    var start: Date = Date.startOfSemester
    var end: Date = Date.endOfSemester
    @Binding var predictedZeroDate: Date
    @Binding var predictedSemesterEndValue: Double
    var displayZeroDate: Bool {
        end >= predictedZeroDate
    }
    var color: Color {
        type == .swipes ? .blue : .green
    }
    var balanceFormat: String {
        type == .swipes ? "%.0f Swipes" : "$%.2f"
    }
    var helpText: String {
        if displayZeroDate {
            return "Based on your current balance and past behavior, we project you'll run out on this date."
        } else {
            return "Based on your past behavior, we project you'll end the semester with \(type == .swipes ? "swipes" : "dollars") to spare."
        }
    }
    var formattedZeroDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d"
        return formatter.string(from: predictedZeroDate)
    }
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                CardHeaderTitleView(color: color, icon: .predictions, title: "\(type == .swipes ? "Swipes" : "Dining Dollars") Predictions")
            }
            Divider()
                .padding([.top, .bottom])
            AnalyticsGraph(data: $data, color: color, start: start, end: end, predictedZeroDate: $predictedZeroDate, predictedSemesterEndValue: $predictedSemesterEndValue, balanceFormat: balanceFormat)
            Divider()
                .padding([.top, .bottom])
            HStack {
                VStack(alignment: .leading) {
                    Text(displayZeroDate ? ("Out of \(type == .swipes ? "Swipes" : "Dollars")") : "Extra Balance")
                        .font(.caption)
                    Text(displayZeroDate ? "\(formattedZeroDate)" : String(format: balanceFormat, predictedSemesterEndValue))
                        .font(Font.system(size: 21, weight: .bold, design: .rounded))
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
