//
//  VariableStepLineGraphView+GraphEndpointPath.swift
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
    
    struct GraphEndpointPath: Shape {
        // The x value of the path (between 0 and 1)
        @State var x: CGFloat
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            path.move(to: CGPoint(
                x: x * rect.maxX,
                y: rect.maxY
            ))
            
            path.addLine(to: CGPoint(
                x: x * rect.maxX,
                y: rect.minY
            ))
            
            return path
        }
    }
}
