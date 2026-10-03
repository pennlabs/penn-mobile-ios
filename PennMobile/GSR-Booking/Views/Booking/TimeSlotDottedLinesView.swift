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
        let avail = vm.getRelevantAvailability()
        // The time at each line: the first slot's start, then every slot's end
        let lineTimes = (avail.first.map { [$0.startTime] } ?? []) + avail.map(\.endTime)
        let highlight = vm.quickBookHighlight

        // Total width should be 80, 79 + 1 (width of line)
        HStack(spacing: GSRTimeCardFilterToggle.width - 1) {
            ForEach(lineTimes.indices, id: \.self) { i in
                // Quick Book draws its time range with solid, thicker lines
                let isHighlighted = highlight?.lowerBound == lineTimes[i] || highlight?.upperBound == lineTimes[i]
                GSRVerticalLine()
                  .stroke(style: isHighlighted ? StrokeStyle(lineWidth: 3) : StrokeStyle(lineWidth: 1, dash: [5]))
                  .foregroundStyle(isHighlighted ? Color("gsrBlue") : Color(UIColor.systemGray))
                  .frame(width: 1)
            }
        }
        .animation(.snappy(duration: 0.2), value: highlight)
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

