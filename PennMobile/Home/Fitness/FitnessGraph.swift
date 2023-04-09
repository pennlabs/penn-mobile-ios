//
//  FitnessGraph.swift
//  PennMobile
//
//  Created by Jordan H on 4/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Charts

struct DataHour: Identifiable {
    let date: Date
    let value: Double
    var id: Date {date}
}

struct FitnessGraph: View {
    private let graphHeight: CGFloat = 100.0
    var data: [String: Double]
    var graphData: [DataHour] {
        let currentDate = Date()
        let calendar = Calendar.current
        let mappedData: [DataHour] = data.map({ key, value in
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)
            components.hour = Int(key)
            return DataHour(date: calendar.date(from: components)!, value: value)
        }).sorted(by: { $0.date < $1.date })
        return mappedData
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(graphData) {
                    BarMark(
                        x: .value("Hour", $0.date, unit: .hour),
                        y: .value("Count", $0.value)
                    )
                    //.foregroundStyle(color)
                }
            }
//            .chartLegend(.hidden)
//            .chartYAxis {
//                AxisMarks(position: .leading, values: labels.1) {
//                    AxisGridLine()
//                    // AxisTick()
//                    AxisValueLabel(anchor: .trailing, collisionResolution: .disabled)
//                }
//            }
//            .chartYScale(domain: 0...maxY)
//            .chartXAxis {
//                AxisMarks(values: labels.0) { value in
//                    AxisGridLine()
//                    // AxisTick(centered: true)
//                    AxisValueLabel(anchor: .top, collisionResolution: .disabled) {
//                        Text(axesDateFormatter.string(from: value.as(Date.self)!))
//                    }
//                }
//            }
//            .chartXScale(domain: start...end)
            .frame(height: graphHeight)
        }
    }
}
