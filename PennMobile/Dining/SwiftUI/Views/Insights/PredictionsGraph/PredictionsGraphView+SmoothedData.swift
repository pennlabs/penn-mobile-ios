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

extension PredictionsGraphView {

    // Compute graph data
    static func getSmoothedData(from trans: [DiningAnalyticsBalance], startOfSemester sos: Date, endOfSemester eos: Date) -> [YXDataPoint] {

        guard sos < eos else { return [] }

        let totalLength = eos.distance(to: sos)
        let maxDollarValue = trans.max(by: { $0.balance < $1.balance })?.balance ?? 1.0
        let yxPoints: [YXDataPoint] = trans.map { (t) -> YXDataPoint in
            let xPoint = t.date.distance(to: sos) / totalLength
            return YXDataPoint(y: CGFloat(t.balance / maxDollarValue), x: CGFloat(xPoint))
        }
        return yxPoints
    }

}
