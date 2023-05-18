//
//  FitnessGraph.swift
//  PennMobile
//
//  Created by Jordan H on 4/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Charts

struct FitnessGraph: View {
    private let graphHeight: CGFloat = 100.0
    private let padding: CGFloat = 10.0
    var room: FitnessRoom
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(room.data?.usageHours ?? []) {
                    BarMark(
                        x: .value("Hour", $0.date, unit: .hour),
                        y: .value("Value", $0.value)
                    )
                    .foregroundStyle(Date().hour == $0.date.hour ? Color.blue.gradient : Color.blue.opacity(0.5).gradient)
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
            .chartXScale(domain: tempCnv(date: room.open)...tempCnv(date: room.close), range: .plotDimension(padding: padding * 2))
            .frame(height: graphHeight)
        }
    }
    
    func tempCnv(date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = 2023
        dateComponents.month = 4
        dateComponents.day = 4
        dateComponents.hour = date.hour
        dateComponents.minute = 0
        dateComponents.second = 0
        return calendar.date(from: dateComponents)!
    }
}

let fitnessAxesDateFormatter: DateFormatter = {
    let result = DateFormatter()
    result.amSymbol = "am"
    result.pmSymbol = "pm"
    result.dateFormat = "ha"
    return result
}()
