//
//  UnavailableTextureOverlay.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 4/25/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct UnavailableTextureOverlay: View {
    let lineSpacing: CGFloat = 10
    let lineWidth: CGFloat = 0.5
    let lineColor: Color = .gray.opacity(0.3)

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let diagonalPath = Path { path in
                    // Calculate how many lines are needed to fill the view
                    let count = Int((size.width + size.height) / lineSpacing)
                    for i in 0...count {
                        let offset = CGFloat(i) * lineSpacing
                        path.move(to: CGPoint(x: offset, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: offset))
                    }
                }

                context.stroke(diagonalPath,
                               with: .color(lineColor),
                               style: StrokeStyle(lineWidth: lineWidth))
            }
            .drawingGroup()
        }
    }
}

#Preview {
    UnavailableTextureOverlay()
}
