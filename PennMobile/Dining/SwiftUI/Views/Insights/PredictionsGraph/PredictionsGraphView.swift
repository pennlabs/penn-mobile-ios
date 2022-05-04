//
//  PredictionsGraphView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

struct PredictionsGraphView: View {

    @Binding var data: [PredictionsGraphView.YXDataPoint]
    @Binding var predictedZeroDate: Date
    @Binding var predictedSemesterEndValue: Double
    @Binding var axisLabelsYX: ([String], [String])
    @Binding var predictedZeroPoint: YXDataPoint

    enum BalanceType {
        case swipes
        case dollars
    }

    let startOfSemester: Date = Date.startOfSemester
    let endOfSemester: Date = Date.endOfSemester

    var formattedZeroDate: String
    var displayZeroDate: Bool
    init(type: String, data: Binding<[PredictionsGraphView.YXDataPoint]>, predictedZeroDate: Binding<Date>, predictedSemesterEndValue: Binding<Double>, axisLabelsYX: Binding<([String],[String])>, predictedZeroPoint: Binding<PredictionsGraphView.YXDataPoint>) {
        self._data = data
        self._predictedZeroDate = predictedZeroDate
        self._predictedSemesterEndValue = predictedSemesterEndValue
        self._axisLabelsYX = axisLabelsYX
        self._predictedZeroPoint = predictedZeroPoint

        balanceType = type.contains("swipes") ? .swipes : .dollars

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d"
        self.formattedZeroDate = formatter.string(from: predictedZeroDate.wrappedValue)

        displayZeroDate = endOfSemester >= predictedZeroDate.wrappedValue

    }

    struct YXDataPoint: Codable {
        var y: CGFloat // Bound between 0 and 1
        var x: CGFloat // Bound between 0 and 1
    }
    var balanceType: PredictionsGraphView.BalanceType

    var formattedBalance: String {
        let b: Double = predictedSemesterEndValue
        return String(format: balanceType == .swipes ? "%.0f" : "%.2f", b)
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
            }
            Divider()
                .padding([.top, .bottom])
            VariableStepLineGraphView(data: $data, lastPointPosition: $data.wrappedValue.last?.x ?? 0, xAxisLabels: $axisLabelsYX.1, yAxisLabels: $axisLabelsYX.0, lineColor: balanceType == .swipes ? .blue : .green, predictedZeroPoint: $predictedZeroPoint)
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
