//
//  AverageDiningPerDayView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/23/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
struct DailyAverageView: View {
    
    init(config: DiningStatisticsAPIResponse.CardData.DailyAverageCardData) {
        self.config = config
        
        var maxSpent = max(config.data.thisWeek.max()?.average ?? 0.0, config.data.lastWeek.max()?.average ?? 0.0)
        if maxSpent == 0 { maxSpent = 1 }
        
        thisWeekDollarData = config.data.thisWeek.map({CGFloat($0.average / maxSpent)})
        lastWeekDollarData = config.data.lastWeek.map({CGFloat($0.average / maxSpent)})
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        dayOfWeek = config.data.thisWeek.map({ String(dayFormatter.string(from: $0.date).first ?? Character(" ")) })
    }
    
    let config: DiningStatisticsAPIResponse.CardData.DailyAverageCardData
    @State private var selectedDataPoint: Int? = nil
    
    private let thisWeekDollarData: [CGFloat]
    private let lastWeekDollarData: [CGFloat]
    
    private let timeFrames = ["This Week", "Last Week"]
    @State private var timeFrame = "This Week"
    @State private var axisOffset: CGFloat = 0.0
    
    private var data: [CGFloat] {
        return timeFrame == "This Week" ? thisWeekDollarData : lastWeekDollarData
    }
    
    private var dayOfWeek: [String]
    
    private var spacingForDollarData: CGFloat {
        return self.data.count <= 7 ? 6 : (self.data.count <= 33 ? 2 : 0)
    }
    
    private var averageDollar: CGFloat {
        return (self.data.reduce(0, +) / CGFloat(self.data.count))
    }
    
    private var formattedAverage: String {
        let maxSpent = max(config.data.thisWeek.max()?.average ?? 0.0, config.data.lastWeek.max()?.average ?? 0.0)
        let spec = "%.2f"
        return String(format: "$\(spec)", Double(averageDollar) * maxSpent)
    }
    
    private var formattedAverageForDay: String {
        let maxSpent = max(config.data.thisWeek.max()?.average ?? 0.0, config.data.lastWeek.max()?.average ?? 0.0)
        let spec = "%.2f"
        if selectedDataPoint == nil {
            return String(format: "$\(spec)", Double(averageDollar) * maxSpent)
        } else {
            return String(format: "$\(spec)", Double(self.data[self.selectedDataPoint!]) * maxSpent)
        }
    }
    
    private var formattedDay: String {
        if selectedDataPoint == nil {
            return "Average"
        } else {
            let df = DateFormatter()
            df.dateFormat = "EEEE M/d"
            let date = timeFrame == "This Week" ? config.data.thisWeek[selectedDataPoint!].date :
                config.data.lastWeek[selectedDataPoint!].date
            return df.string(from: date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Top labels
            Group {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Dining Dollars")
                }
                .font(Font.body.weight(.medium))
                .foregroundColor(.green)
                
                Text("Over the \(self.timeFrame == "This Week" ? "last 7 days" : "7 days before that"), you spent an average of \(formattedAverage) dining dollars per day.")
                    .fontWeight(.medium)
            }
            
            // Graph view
            Spacer()
            ZStack {
                HStack(alignment: .bottom) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 120.0, height: 110.0)
                        VStack(alignment: .leading) {
                            Text(self.selectedDataPoint == nil ? "Average" : formattedDay) .font(Font.caption.weight(.bold)).foregroundColor(self.selectedDataPoint == nil ? .gray : .yellow)
                                .offset(x: 0, y: self.axisOffset - 10)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(formattedAverageForDay)
                                    .font(Font.system(.title, design: .rounded).bold())
                                    .offset(x: 0, y: self.axisOffset - 10)
                                Text("\(self.selectedDataPoint == nil ? "/ day" : "")").font(Font.caption.weight(.bold)).foregroundColor(.gray)
                                    .offset(x: 0, y: self.axisOffset - 10)
                                
                            }
                            .padding(.top, 8)
                        }
                        .frame(height: 110)
                        
                    }
                    // Graph pillars and caption
                    HStack(alignment: .bottom, spacing: self.spacingForDollarData) {
                        ForEach(self.data.indices, id: \.self) { i in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 4).frame(height: 110.0 * self.data[i])
                                    .foregroundColor(
                                        self.selectedDataPoint == i ? Color.yellow : Color.gray.opacity(0.3))
                                    .onTapGesture {
                                        if self.selectedDataPoint == i {
                                            self.selectedDataPoint = nil
                                        } else {
                                            self.selectedDataPoint = i
                                        }
                                        withAnimation {
                                            self.axisOffset = (self.selectedDataPoint == nil ? ((0.5 - self.averageDollar) * 110) : ((0.5 - self.data[self.selectedDataPoint!]) * 110))
                                        }
                                }
                                Text(self.dayOfWeek[i])
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .animation(.default)
                }
                GraphPath(data: [0.5, 0.5, 0.5]).stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundColor(self.selectedDataPoint == nil ? .green : Color.gray.opacity(0.5))
                    .animation(.default)
                    .offset(x: 0, y: self.axisOffset - 2)
                    .animation(.default)
            }
            
            // Footer
            Picker("Pick a time frame", selection: self.$timeFrame) {
                ForEach(self.timeFrames, id: \.self) { time in
                    Text(time)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onReceive([self.timeFrame].publisher.first()) { (output) in
                withAnimation {
                    self.axisOffset = (self.selectedDataPoint == nil ? ((0.5 - self.averageDollar) * 110) : ((0.5 - self.data[self.selectedDataPoint!]) * 110))
                }
            }
            .padding(.top, 5)
        }
        .frame(height: 264)
        .padding()
    }
}

@available(iOS 13, *)
struct GraphPath: Shape, Animatable {
    @State var data: [CGFloat]
    
    var animatableData: [CGFloat] {
        get { return data }
        set { data = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard data.count > 2 else { return path }
        
        func point(at n: Int) -> CGPoint {
            return CGPoint(x: CGFloat(n) * (rect.maxX / CGFloat(data.count - 1)), y: rect.maxY - (rect.maxY * data[n]))
        }
        
        path.move(to: point(at: 0))
        
        for i in 1 ..< data.count {
            path.addLine(to: point(at: i))
        }
        
        return path
    }
}
