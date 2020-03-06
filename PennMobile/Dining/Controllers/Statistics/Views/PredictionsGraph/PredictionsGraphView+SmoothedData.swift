//
//  PredictionsGraphView+SmoothedData.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
extension PredictionsGraphView {

    // Compute graph data
    static func getSmoothedData(from trans: [DiningInsightsAPIResponse.CardData.PredictionsGraphCardData.DiningBalance], startOfSemester sos: Date, endOfSemester eos: Date) -> [YXDataPoint] {
        
        guard sos < eos else { return [] }
        
        let totalLength = eos.distance(to: sos)
        let maxDollarValue = trans.max(by: { $0.balance < $1.balance })?.balance ?? 1.0
        let yxPoints: [YXDataPoint] = trans.map { (t) -> YXDataPoint in
            let xPoint = t.date.distance(to: sos) / totalLength
            return YXDataPoint(y: CGFloat(t.balance / maxDollarValue), x: CGFloat(xPoint))
        }
        return yxPoints
    }
    
    static func getPredictionZeroPoint(from trans: [DiningInsightsAPIResponse.CardData.PredictionsGraphCardData.DiningBalance], startOfSemester sos: Date, endOfSemester eos: Date, predictedZeroDate zpd: Date) -> PredictionsGraphView.YXDataPoint {

        guard sos < eos else { return .init(y: 0.0, x: 0.0) }

        let fullSemester = sos.distance(to: eos)
        let fullZeroDistance = sos.distance(to: zpd)
        
        // x value, may be > 1 if the zero date is past end of semester
        let x = (fullZeroDistance / fullSemester)
        
        // y value is always zero
        return .init(y: 0.0, x: CGFloat(x))
    }
}
