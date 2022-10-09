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

        // Slope of line to be drawn from lastDataPoint
        @State var slope: Double = 0.0

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
            if slope.isInfinite {
                // This case should never actually execute, but it's caught just in case to prevent undefined behavior
                path.addLine(to: CGPoint(
                    x: rect.maxX,
                    y: rect.maxY - (rect.maxY * lastDataPoint.y)
                ))
            } else {
                path.addLine(to: CGPoint(
                    x: rect.maxX,
                    y: rect.maxY * (1 - lastDataPoint.y - slope * (1 - lastDataPoint.x))
                ))
            }

            return path
        }
    }
}
