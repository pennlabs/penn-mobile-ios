//
//  PredictionsGraphView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

// TODO: - Move these protocols to Protocols.swift
protocol ClampableRange {
    associatedtype Bound: Comparable
    var upperBound: Bound { get }
    var lowerBound: Bound { get }
}
extension ClampableRange {
    func clamp(_ value: Bound) -> Bound {
        return min(max(lowerBound, value), upperBound)
    }
}
extension Range: ClampableRange {}
extension ClosedRange: ClampableRange {}
// END TODO

// VariableStepLineGraphView.getSmoothedData(from: DiningTransaction.sampleData)
@available(iOS 14, *)
struct PredictionsGraphView: View {

    init(config: DiningInsightsAPIResponse.CardData.PredictionsGraphCardData) {

        self.config = config
        data = PredictionsGraphView.getSmoothedData(from: config.data, startOfSemester: config.startOfSemester, endOfSemester: config.endOfSemester)

        axisLabelsYX = PredictionsGraphView.getAxisLabelsYX(from: config.data, startOfSemester: config.startOfSemester, endOfSemester: config.endOfSemester)

        balanceType = config.type.contains("swipes") ? .swipes : .dollars

        predictedZeroPoint = PredictionsGraphView.getPredictionZeroPoint(from: config.data, startOfSemester: config.startOfSemester, endOfSemester: config.endOfSemester, predictedZeroDate: config.predictedZeroDate)
    }

    struct YXDataPoint {
        var y: CGFloat // Bound between 0 and 1
        var x: CGFloat // Bound between 0 and 1
    }

    var config: DiningInsightsAPIResponse.CardData.PredictionsGraphCardData
    var data: [YXDataPoint]
    var axisLabelsYX: ([String], [String])
    var balanceType: DiningInsightsAPIResponse.CardData.PredictionsGraphCardData.BalanceType
    var predictedZeroPoint: YXDataPoint

    var formattedZeroDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d"
        return formatter.string(from: self.config.predictedZeroDate)
    }

    var displayZeroDate: Bool {
        if config.predictedZeroDate > config.endOfSemester && config.semesterEndBalance != nil {
            return false
        }
        return true
    }

    var formattedBalance: String {
        let b: Double = config.semesterEndBalance ?? 0
        return String(format: balanceType == .swipes ? "%g" : "%.2f", b)
    }

    var helpText: String {
        if displayZeroDate {
            return "Based on your current balance and past behavior, we project you'll run out on this date."
        } else {
            return "Based on your past behavior, we project you'll end the semester with \(balanceType == .swipes ? "swipes" : "dollars") to spare."
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                CardHeaderTitleView(color: balanceType == .swipes ? .blue : .green, icon: .predictions, title: "\(balanceType == .swipes ? "Swipes" : "Dining Dollars") Predictions")
                Text("Log into Penn Mobile often to get more accurate predictions.")
                .fontWeight(.medium)
                .lineLimit(nil)
                .frame(height: 44)
            }
            Divider()
                .padding([.top, .bottom])
            VariableStepLineGraphView(data: self.data, lastPointPosition: self.data.last?.x ?? 0, xAxisLabels: axisLabelsYX.1, yAxisLabels: axisLabelsYX.0, lineColor: balanceType == .swipes ? .blue : .green, predictedZeroPoint: self.predictedZeroPoint)
            Divider()
            .padding([.top, .bottom])

            HStack {
                VStack(alignment: .leading) {
                    // "Leftover" Dollars, wasted dollars
                    Text(displayZeroDate ? ("Out of \(balanceType == .swipes ? "Swipes" : "Dollars")") : "Extra Balance")
                        .font(.caption)
                    Text(displayZeroDate ? "\(self.formattedZeroDate)" : "\(formattedBalance)\(balanceType == .swipes ? " Swipes" : " Dollars")")
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
