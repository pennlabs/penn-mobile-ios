//
//  PredictionsGraphView+AxisLabels.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/29/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
extension PredictionsGraphView {

    static let xAxisLabelCount = 4
    static let yAxisLabelCount = 5

    // Compute axis labels
    static func getAxisLabelsYX(from trans: [DiningInsightsAPIResponse.CardData.PredictionsGraphCardData.DiningBalance], startOfSemester sos: Date, endOfSemester eos: Date) -> ([String], [String]) {

        var xLabels: [String] = []
        var yLabels: [String] = []

        guard sos < eos else { return ([" "],[" "]) }

        // Generate Y Axis Labels
        let maxDollarValue = trans.max(by: { $0.balance < $1.balance })?.balance ?? 1.0
        let dollarStep = (maxDollarValue / Double(yAxisLabelCount - 1))
        for i in 0 ..< yAxisLabelCount {
            let yAxisLabel = "\(Int(dollarStep * Double(yAxisLabelCount - i - 1)))"
            yLabels.append(yAxisLabel)
        }

        // Generate X Axis Labels
        let semester = sos.distance(to: eos)
        let semesterStep = semester / Double(xAxisLabelCount - 1)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        for i in 0 ..< xAxisLabelCount {
            let dateForLabel = sos.advanced(by: semesterStep * Double(i))
            xLabels.append(dateFormatter.string(from: dateForLabel))
        }

        return (yLabels, xLabels)
    }
}
