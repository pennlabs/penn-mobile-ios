//
//  PredictionsGraph+VariableStepGraph.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
extension VariableStepLineGraphView {
    struct VariableStepGraphPath: Shape, Animatable {
        @State var data: [PredictionsGraphView.YXDataPoint]
        
        var animatableData: [PredictionsGraphView.YXDataPoint] {
            get { return data }
            set { data = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            guard data.count > 2 else { return path }
            
            func point(at n: Int) -> CGPoint {
                return CGPoint(
                    x: data[n].x * rect.maxX,
                    y: rect.maxY - (rect.maxY * data[n].y))
            }
            
            path.move(to: point(at: 0))
            
            for i in 1 ..< data.count {
                path.addLine(to: point(at: i))
            }
            
            return path
        }
    }
}
