//
//  TimeSlotDottedLinesView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct TimeSlotDottedLinesView: View {
    @EnvironmentObject var vm: GSRViewModel
    var body: some View {
        // Total width should be 80, 79 + 1 (width of line)
        HStack(spacing: GSRTimeCardFilterToggle.width - 1) {
            ForEach(0..<(vm.getRelevantAvailability().count + 1), id: \.self) { _ in
                GSRVerticalLine()
                  .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                  .foregroundStyle(Color(UIColor.systemGray))
                  .frame(width: 1)
            }
        }
    }
}

struct GSRVerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

