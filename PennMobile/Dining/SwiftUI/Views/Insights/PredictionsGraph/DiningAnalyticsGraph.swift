//
//  DiningAnalyticsGraph.swift
//  PennMobile
//
//  Created by Jordan H on 1/27/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Charts

struct AnalyticsGraph: View {
    private let graphHeight: CGFloat = 180.0
    @Binding var data: [DiningAnalyticsBalance]
    var color: Color = Color.blue
    var start: Date = Date.startOfSemester
    var end: Date = Date.endOfSemester
    var xAxisLabelCount: Int = 5
    var yAxisLabelCount: Int = 4
    @Binding var predictedZeroDate: Date
    @Binding var predictedSemesterEndValue: Double
    var balanceFormat: String
    var displayZeroDate: Bool {
        end >= predictedZeroDate
    }
    var predictionLineData: [DiningAnalyticsBalance] {
        if data.last == nil || data.last!.date < start {
            return []
        } else {
            if displayZeroDate {
                return [data.last!, DiningAnalyticsBalance(date: predictedZeroDate, balance: 0)]
            } else {
                return [data.last!, DiningAnalyticsBalance(date: end, balance: predictedSemesterEndValue)]
            }
        }
    }
    var maxY: Double {
        data.max(by: { $0.balance < $1.balance })?.balance ?? 300.0
    }
    var labels: ([Date], [Double]) {
        (getXLabels(xAxisLabelCount: xAxisLabelCount), getYLabels(yAxisLabelCount: yAxisLabelCount))
    }
    @State var showInfo = false
    @State var tapLocation: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State var tapDate: Date = Date.startOfSemester
    @State var tapBalance: Double = 0.0
    @State var isPrediction: Bool = false
    var body: some View {
        if #available(iOS 16.0, *) {
            ZStack {
                Chart {
                    ForEach(data) {
                        LineMark(
                            x: .value("Day", $0.date, unit: .day),
                            y: .value("Balance", $0.balance)
                        )
                        .foregroundStyle(color)
                        .foregroundStyle(by: .value("Type", "Data"))
                    }
                    ForEach(predictionLineData) {
                        LineMark(
                            x: .value("Day", $0.date, unit: .day),
                            y: .value("Balance", $0.balance)
                        )
                        .foregroundStyle(Color.gray)
                        .foregroundStyle(by: .value("Type", "Prediction"))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    }
                    RuleMark(x: .value("End of Term", end))
                        .foregroundStyle(Color.red)
                        .annotation(alignment: .trailing) {
                            Text("End of Term")
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                    PointMark(x: .value("End of Term", end), y: .value("End of Term", maxY))
                        .foregroundStyle(Color.red)
                    if showInfo {
                        PointMark(x: .value("Tap", tapDate), y: .value("Tap", tapBalance))
                            .foregroundStyle(isPrediction ? Color.gray : color)
                    }
                }
                .chartLegend(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: labels.1) {
                        AxisGridLine()
                        // AxisTick()
                        AxisValueLabel(anchor: .trailing, collisionResolution: .disabled)
                    }
                }
                .chartYScale(domain: 0...maxY)
                .chartXAxis {
                    AxisMarks(values: labels.0) { value in
                        AxisGridLine()
                        // AxisTick(centered: true)
                        AxisValueLabel(anchor: .top, collisionResolution: .disabled) {
                            Text(axesDateFormatter.string(from: value.as(Date.self)!))
                        }
                    }
                }
                .chartXScale(domain: start...end)
                .frame(height: graphHeight)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        // Convert the gesture location to the coordiante space of the plot area
                                        let origin = geometry[proxy.plotAreaFrame].origin
                                        let location = CGPoint(
                                            x: value.location.x - origin.x,
                                            y: value.location.y - origin.y
                                        )
                                        // Get the x (date) and y (balance) value from the tap location (balance from tap location, not line location
                                        let (date, _) = proxy.value(at: location, as: (Date, Double).self) ?? (start, 0)
                                        // Get the actual balance at date, from non predicted data
                                        var balance = data.last(where: {$0.date <= date})?.balance ?? -1.0
                                        isPrediction = false
                                        // Get actual balance at date, from predicted data
                                        if predictionLineData.count != 0 && predictionLineData[0].date < date {
                                            // Ensuring prediction line exists and is valid
                                            if let predStart = proxy.position(for: (x: predictionLineData[0].date, y: predictionLineData[0].balance)),
                                               let predEnd = proxy.position(for: (x: predictionLineData[1].date, y: predictionLineData[1].balance)) {
                                                // Get slope of line, and then predicted balance
                                                let slope = (predEnd.y - predStart.y) / (predEnd.x - predStart.x)
                                                balance = proxy.value(atY: slope * (location.x - predStart.x) + predStart.y) ?? -1.0
                                                isPrediction = true
                                            }
                                        }
                                        // Get graph coordinate of balance
                                        let coordOfBalance = proxy.position(forY: balance) ?? 0.0
                                        // Check if position is on screen (and balance is valid)
                                        showInfo = balance != -1.0 && 0 <= location.x && location.x <= proxy.plotAreaSize.width && coordOfBalance >= 0 && coordOfBalance <= proxy.plotAreaSize.height
                                        // Get pixel position of where to display (relative to whole screen)
                                        tapLocation = CGPoint(x: value.location.x, y: coordOfBalance + origin.y)
                                        tapDate = date
                                        tapBalance = balance
                                    }
                                    .onEnded { _ in
                                        showInfo = false
                                    }
                            )
                    }
                }
                if showInfo {
                    ZoomInfo(location: tapLocation, date: tapDate, balance: tapBalance, balanceFormat: balanceFormat, color: isPrediction ? Color.gray : color)
                }
            }
        }
    }
    func getXLabels(xAxisLabelCount: Int = 5) -> [Date] {
        var xLabels: [Date] = []
        let semester = start.distance(to: end)
        let semesterStep = semester / Double(xAxisLabelCount - 1)
        for i in 0 ..< xAxisLabelCount {
            let dateForLabel = start.advanced(by: semesterStep * Double(i))
            xLabels.append(dateForLabel)
        }
        return xLabels
    }
    func getYLabels(yAxisLabelCount: Int = 4) -> [Double] {
        var yLabels: [Double] = []
        let dollarStep = (maxY / Double(yAxisLabelCount - 1))
        for i in 0 ..< yAxisLabelCount {
            let yAxisLabel = dollarStep * Double(yAxisLabelCount - i - 1)
            yLabels.append(yAxisLabel)
        }
        return yLabels
    }
}

struct ZoomInfo: View {
    var location: CGPoint
    var date: Date
    var balance: Double
    var balanceFormat: String
    var color: Color
    var body: some View {
        ZStack {
            // Circle()
            //     .stroke(color, lineWidth: 4)
            //     .frame(width: 50, height: 50)
            // ADD SOME OTHER DESIGN
            VStack {
                Text(infoDateFormatter.string(from: date))
                    .foregroundColor(color)
                    .font(.caption)
                Text(String(format: balanceFormat, balance))
                    .foregroundColor(color)
                    .font(.caption)
            }
        }
        .position(x: min(location.x + 25, UIScreen.main.bounds.size.width - 75), y: location.y - 25)
    }
}

let axesDateFormatter: DateFormatter = {
    let result = DateFormatter()
    result.dateFormat = "M/d"
    return result
}()

let infoDateFormatter: DateFormatter = {
    let result = DateFormatter()
    result.dateFormat = "MMM. d"
    return result
}()
