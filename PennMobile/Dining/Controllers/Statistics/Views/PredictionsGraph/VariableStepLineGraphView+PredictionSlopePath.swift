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

@available(iOS 13, *)
extension VariableStepLineGraphView {
    
    struct PredictionSlopePath: Shape, Animatable {
        // This should be the last data point before prediction line begins
        @State var data: PredictionsGraphView.YXDataPoint
        
        // Calculated on a "per-day" basis. Should only take negative transactions into account.
        // Slope is defined in terms of the max dollar change (full balance to 0) over the max time frame
        @State var predictionSlope: CGFloat
        
        var animatableData: PredictionsGraphView.YXDataPoint {
            get { return data }
            set { data = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            path.move(to: CGPoint(
                x: data.x * rect.maxX,
                y: rect.maxY - (rect.maxY * data.y)
            ))
            
            path.addLine(to: CGPoint(
                x: rect.maxX,
                y: rect.maxY - (rect.maxY * predictionSlope)
            ))
            
            return path
        }
    }
}
