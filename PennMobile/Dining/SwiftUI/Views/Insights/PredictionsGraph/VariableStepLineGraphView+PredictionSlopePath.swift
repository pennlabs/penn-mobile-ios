//
//  VariableStepLineGraphView+PredictionSlopePath.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

extension VariableStepLineGraphView {

    struct PredictionSlopePath: Shape, Animatable {
        // This should be the last data point before prediction line begins
        @State var lastDataPoint: PredictionsGraphView.YXDataPoint

        // Calculated day balance will reach 0, computed by the server. X may exceed 1.0 if the zero date is past the end of the semester
        @State var predictionZeroPoint: PredictionsGraphView.YXDataPoint

        var animatableData: PredictionsGraphView.YXDataPoint {
            get { return lastDataPoint }
            set { lastDataPoint = newValue }
        }

        func path(in rect: CGRect) -> Path {
            var path = Path()

            path.move(to: CGPoint(
                x: lastDataPoint.x * rect.maxX,
                y: rect.maxY - (rect.maxY * lastDataPoint.y)
            ))

            path.addLine(to: CGPoint(
                x: predictionZeroPoint.x * rect.maxX,
                y: rect.maxY - (rect.maxY * predictionZeroPoint.y)
            ))

            return path
        }
    }
}
