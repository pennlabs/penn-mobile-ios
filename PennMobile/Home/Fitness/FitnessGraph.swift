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
    var room: FitnessRoom
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(room.data?.usageHours ?? []) {
                    BarMark(
                        x: .value("Hour", $0.date, unit: .hour),
                        y: .value("Value", $0.value)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(5)
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4, roundLowerBound: true, roundUpperBound: true)) { value in
                    AxisValueLabel(anchor: .top, collisionResolution: .disabled) {
                        Text(fitnessAxesDateFormatter.string(from: value.as(Date.self)!))
                            .foregroundColor(Color.labelPrimary)
                    }
                }
            }
            .chartXScale(domain: tempCnv(date: room.open)...tempCnv(date: room.close), range: .plotDimension(padding: 20))
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
        if room.id == 3 {
            print("MAX: \(room.data?.usageHours.filter({ $0.value > 0 }).min(by: { $0.date.hour < $1.date.hour })!.date.hour)")
            print("MAX: \(room.data?.usageHours.filter({ $0.value > 0 }).max(by: { $0.date.hour < $1.date.hour })!.date.hour)")
            print("HOUR: \(date.hour)")
            print(room.data?.usageHours.count)
            //room.data?.usageHours.map { print("\($0.date.hour)\t\($0.value)") }
        }
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
