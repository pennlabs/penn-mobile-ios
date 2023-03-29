//
//  MeterView.swift
//  PennMobile
//
//  Created by Anthony Li on 11/5/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct MeterView<S: ShapeStyle, Content: View>: View {
    var current: Double
    var maximum: Double
    var style: S
    var lineWidth: CGFloat
    var content: Content

    init(current: Double, maximum: Double, style: S = Color.primary, lineWidth: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.current = current
        self.maximum = maximum
        self.style = style
        self.lineWidth = lineWidth
        self.content = content()
    }

    var body: some View {
        ZStack {
            GeometryReader { _ in
                Rectangle()
                .fill(style)
                .mask(alignment: .center) {
                    ZStack {
                        Circle().stroke(Color.black.opacity(0.2), lineWidth: lineWidth)
                        Circle()
                            .trim(from: 0, to: max(0, min(current / maximum, 1)))
                            .rotation(.degrees(-90))
                            .stroke(Color.black, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    }.padding(lineWidth / 2)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            content
        }
    }
}
