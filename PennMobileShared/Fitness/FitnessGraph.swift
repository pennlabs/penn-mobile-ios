//
//  FitnessGraph.swift
//  PennMobile
//
//  Created by Jordan H on 4/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Charts

public struct FitnessGraph: View {
    
    private let graphHeight: CGFloat = 100.0
    private let padding: CGFloat = 10.0
    public var room: FitnessRoom
    public var color: Color
    
    public init(room: FitnessRoom, color: Color) {
        self.room = room
        self.color = color
    }
    
    var hours: (Date, Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        let weekdayIndex = (calendar.component(.weekday, from: currentDate) + 5) % 7
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        let openTime = timeFormatter.date(from: room.open[weekdayIndex])!
        let closeTime = timeFormatter.date(from: room.close[weekdayIndex])!

        let openDate = calendar.date(bySettingHour: openTime.hour, minute: openTime.minutes, second: 0, of: currentDate)!
        let closeDate = calendar.date(bySettingHour: closeTime.hour, minute: closeTime.minutes, second: 0, of: currentDate)!
        
        return (openDate, closeDate)
    }
    
    public var body: some View {
        Chart {
            ForEach(room.data?.usageHours ?? []) {
                BarMark(
                    x: .value("Hour", $0.date, unit: .hour),
                    y: .value("Value", $0.value)
                )
                .foregroundStyle(Date().hour == $0.date.hour ? color.gradient : color.opacity(0.5).gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: -padding)
            }
            RuleMark(
                y: .value("Axis", 0)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(Color.labelPrimary)
            .offset(y: 6)
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...(room.data?.usageHours.max { $0.value < $1.value }?.value ?? 100))
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .automatic(desiredCount: 4, roundLowerBound: true, roundUpperBound: true)) { value in
                AxisGridLine()
                    .offset(x: -padding)
                AxisTick()
                    .offset(x: -padding)
                AxisValueLabel(anchor: .top, collisionResolution: .disabled) {
                    Text(fitnessAxesDateFormatter.string(from: value.as(Date.self)!))
                        .foregroundColor(Color.labelPrimary)
                }
                .offset(x: -padding, y: 6)
            }
        }
        .chartXScale(domain: (hours.0)...(hours.1), range: .plotDimension(padding: padding * 2))
        .frame(height: graphHeight)
    }
}

let fitnessAxesDateFormatter: DateFormatter = {
    let result = DateFormatter()
    result.amSymbol = "am"
    result.pmSymbol = "pm"
    result.dateFormat = "ha"
    return result
}()
