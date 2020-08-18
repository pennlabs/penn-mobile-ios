//
//  FadingScrollView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/7/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct FadingScrollView<Content: View>: View {
    let fadeDistance: CGFloat
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content

    init(
        fadeDistance: CGFloat,
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.fadeDistance = fadeDistance
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView(axes, showsIndicators: showsIndicators) {
                // Pad the content depending on the axes so that bottom or trailing
                // part of the content isn't faded when scrolling all the way to the end.
                
                if axes == .vertical {
                    Spacer(minLength: fadeDistance)
                    
                    content
                    
                    Spacer(minLength: fadeDistance)
                } else if axes == .horizontal {
                    HStack(spacing: 0) {
                        Spacer(minLength: fadeDistance)

                        content
                        
                        Spacer(minLength: fadeDistance)
                    }
                }
            }

            if axes.contains(.vertical) {
                VStack {
                    fadeGradient(for: .vertical, startPoint: .top, endPoint: .bottom)
                        .frame(height: fadeDistance)
                        // SwiftUI internally not working
                        .allowsHitTesting(false)
                    
                    Spacer()
                    
                    fadeGradient(for: .vertical, startPoint: .bottom, endPoint: .top)
                        .frame(height: fadeDistance)
                        // SwiftUI internally not working
                        .allowsHitTesting(false)
                }
            }


            if axes.contains(.horizontal) {
                HStack {
                    fadeGradient(for: .horizontal, startPoint: .leading, endPoint: .trailing)
                        .frame(width: fadeDistance)
                    .allowsHitTesting(false)
                    Spacer()
                    fadeGradient(for: .horizontal, startPoint: .trailing, endPoint: .leading)
                        .frame(width: fadeDistance)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    private func fadeGradient(for axis: Axis, startPoint: UnitPoint, endPoint: UnitPoint) -> some View {
        return LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground).opacity(1),
                Color(.systemBackground).opacity(0)
            ]),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
