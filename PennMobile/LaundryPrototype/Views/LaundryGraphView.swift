//
//  LaundryGraphView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Charts

struct LaundryGraphView: View {
    let usageData: UsageData

    private var series: [HourUsage] {
        usageData.normalizedHourlyUsage()
    }

    private var lineColor: Color { .baseLabsBlue }
    private var fillTop: Color { .baseLabsBlue.opacity(0.8) }
    private var fillBottom: Color { .baseLabsBlue.opacity(0.1) }
    private let hoursPerTick: Int = 2
    private let xLabel: String = "Hour"
    private let yLabel: String = "Load"
    private let displayRange: ClosedRange<Double> = 0...1.5
    private let date: Date = Date()

    var body: some View {
        Chart(series) { point in
            AreaMark(
                x: .value(xLabel, point.hour),
                y: .value(yLabel, point.normalizedLoad)
            )
            .foregroundStyle(LinearGradient(
                colors: [fillTop, fillBottom],
                startPoint: .top,
                endPoint: .bottom
            ))

            LineMark(
                x: .value(xLabel, point.hour),
                y: .value(yLabel, point.normalizedLoad)
            )
            .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round))
            .foregroundStyle(lineColor)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 2)) { value in
                AxisTick()
                if let hour = value.as(Int.self) {
                    AxisValueLabel(Date.shortHourLabel(for: hour))
                        .foregroundStyle(.labelSecondary)
                }
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: displayRange)
        .chartOverlay { proxy in
            let currentHour: Int = date.hour
            if series.contains(where: { $0.hour == currentHour }) {
                let xPos = proxy.position(forX: currentHour) ?? 0
                GeometryReader { geo in
                    Path { path in
                        path.move(to: CGPoint(x: xPos, y: 0))
                        path.addLine(to: CGPoint(x: xPos, y: geo.size.height))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5]))
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
