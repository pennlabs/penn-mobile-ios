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
    
    static func getPredictionLineSlope(from trans: [DiningInsightsAPIResponse.CardData.PredictionsGraphCardData.DiningBalance], startOfSemester sos: Date, endOfSemester eos: Date, predictedZeroDate zpd: Date) -> Double {
        
        // TODO: Fix this, the logic is slightly wrong
        // TODO: Add actual OUT date to the UI
        
        guard sos < eos else { return 0.0 }
        guard let last = trans.last else { return 0.0 }
        
        let maxBalance = trans.max(by: { $0.balance < $1.balance })?.balance ?? 1.0
        
        let fullSemester = sos.distance(to: eos)
        let remainingSemester = last.date.distance(to: eos)
        let zeroDistance = sos.distance(to: zpd)
        
        let percentageSemesterElapsed = ((fullSemester - remainingSemester) / fullSemester)
        let percentageBalanceSpent = (last.balance / maxBalance)
        
        let fullBalancePercentageSpent = 1.0
        let fullElapsedTime = ((fullSemester - zeroDistance) / fullSemester)
        
        let slope = (fullBalancePercentageSpent - percentageBalanceSpent) / (fullElapsedTime - percentageSemesterElapsed)
        
        return slope
        
        //(0.66 done, 0.3 spent)
        //(1.33 done,    1.0 spent)
        
        // rise == balance
        // run == time
        
        // 0.3 - 1.0 = -0.7
        // 1.33 - 0.66 = 0.66
        // -1.06
        
        // slope is rise over run
        // -balance as a percentage of total
        // over
        // -date as a percentage
        
        // 0.66
    }
}
