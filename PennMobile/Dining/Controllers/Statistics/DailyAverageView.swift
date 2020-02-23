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
    var body: some View {
        CardView {
            VStack(alignment: .leading) {
                // Top labels
                Group {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("Dining Dollars")
                    }
                    .font(Font.body.weight(.medium))
                    .foregroundColor(.green)
                    
                    Text("Over the last 7 days, you spent an average of 7.49 dining dollars per day.")
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
                                Text(self.selectedData == nil ? "Average" : self.dayValue + " 12/14") .font(Font.caption.weight(.bold)).foregroundColor(self.selectedData == nil ? .gray : .yellow)
                                    .offset(x: 0, y: self.axisOffset - 10)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("$\(14.47 * (self.selectedData == nil ? self.averageDollar : (self.dollarData[self.selectedData!])), specifier: "%.2f")")
                                        .font(Font.system(.title, design: .rounded).bold())
                                        .offset(x: 0, y: self.axisOffset - 10)
                                    Text("\(self.selectedData == nil ? "/ day" : "")").font(Font.caption.weight(.bold)).foregroundColor(.gray)
                                        .offset(x: 0, y: self.axisOffset - 10)
                                    
                                }
                                .padding(.top, 8)
                            }
                            .frame(height: 110)
                            
                        }
                        // Graph pillars and caption
                        HStack(alignment: .bottom, spacing: self.spacingForDollarData) {
                            ForEach(self.dollarData.indices, id: \.self) { i in
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 4).frame(height: 110.0 * self.dollarData[i])
                                        .foregroundColor(
                                            self.selectedData == i ? Color.yellow : Color.gray.opacity(0.3))
                                        .onTapGesture {
                                            if self.selectedData == i {
                                                self.selectedData = nil
                                            } else {
                                                self.selectedData = i
                                            }
                                            withAnimation {
                                                self.axisOffset = (self.selectedData == nil ? ((0.5 - self.averageDollar) * 110) : ((0.5 - self.dollarData[self.selectedData!]) * 110))
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
                        .foregroundColor(self.selectedData == nil ? .green : Color.gray.opacity(0.5))
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
                        self.axisOffset = (self.selectedData == nil ? ((0.5 - self.averageDollar) * 110) : ((0.5 - self.dollarData[self.selectedData!]) * 110))
                    }
                }
                .padding(.top, 5)
            }
            .padding()
        }
        .frame(height: 296)
        .padding()
    }
}
