//
//  PredictionsGraphView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

// TODO: - Move these protocols to Protocols.swift
protocol ClampableRange {
    associatedtype Bound : Comparable
    var upperBound: Bound { get }
    var lowerBound: Bound { get }
}
extension ClampableRange {
    func clamp(_ value: Bound) -> Bound {
        return min(max(lowerBound, value), upperBound)
    }
}
extension Range: ClampableRange {}
extension ClosedRange: ClampableRange {}
// END TODO

//VariableStepLineGraphView.getSmoothedData(from: DiningTransaction.sampleData)
@available(iOS 13, *)
struct PredictionsGraphView: View {
    
    init(config: DiningInsightsAPIResponse.CardData.PredictionsGraphCardData) {
        self.config = config
        _data = State(initialValue: PredictionsGraphView.getSmoothedData(from: config.data))
    }
    
    struct YXDataPoint {
        var y: CGFloat // Bound between 0 and 1
        var x: CGFloat // Bound between 0 and 1
    }
    
    let config: DiningInsightsAPIResponse.CardData.PredictionsGraphCardData
    @State var data: [PredictionsGraphView.YXDataPoint]
    
    var body: some View {
        CardView {
            VStack(alignment: .leading) {
                CardHeaderView(color: .blue, icon: .predictions, title: "Swipes Predictions", subtitle: "Log into Penn Mobile often to get more accurate predictions.")
                    .frame(height: 60)
                Divider()
                    .padding([.top, .bottom])
                VariableStepLineGraphView(data: self.data, lastPointPosition: self.data.last?.x ?? 0)
                Divider()
                .padding([.top, .bottom])
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Out of Swipes")
                            .font(.caption)
                        Text("Dec. 15th")
                            .font(Font.system(size: 21, weight: .bold, design: .rounded))
                        Spacer()
                    }
                    .padding(.trailing)
                    VStack {
                        Text("Based on your current balance and past behavior, we project you have this many days of balance remaining.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        Spacer()
                    }
                }.frame(height: 60)
            }
            .padding()
        }
        .padding()
    }
}

@available(iOS 13, *)
struct VariableStepLineGraphView: View {
    
    private let graphHeight: CGFloat = 160.0
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var trimEnd: CGFloat = 0.0
    @GestureState private var dragActive = false
    @State var data: [PredictionsGraphView.YXDataPoint]
    @State var lastPointPosition: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 20)
            HStack {
                // Y-Axis labels
                VStack(alignment: .leading) {
                    ForEach(0 ..< 5) { num in
                        if num != 0 { Spacer() }
                        Text(String(2200 - (440 * num)))
                            .font(.subheadline)
                            .opacity(0.5)
                    }
                }
                .frame(width: 40, height: self.graphHeight)
                
                GeometryReader { geometry in
                    
                    ZStack {
                        
                        VariableStepGraphPath(data: self.data).trim(from: 0, to: self.trimEnd).stroke(
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                            .foregroundColor(.blue)
                            .frame(height: self.graphHeight)
                            .animation(.default)
                            .onAppear {
                                self.trimEnd = 1.0
                        }
                        
                        
                        PredictionSlopePath(data: self.data.last!, predictionSlope: -0.2).stroke(
                            style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round, dash: [5], dashPhase: 5)
                        )
                            .foregroundColor(.gray)
                            .frame(height: self.graphHeight)
                            .animation(.default)
                            .onAppear {
                                self.trimEnd = 1.0
                        }
                        .clipped()
                        
                        Group {
                            Group {
                                HStack(alignment: .center) {
                                    Spacer()
                                    Text("Today")
                                    Image(systemName: "circle.fill")
                                }
                                .foregroundColor(.white)
                                .font(.caption)
                            }
                            .frame(width: 140)
                            .offset(x: -70 + 5.5 + ((self.lastPointPosition - 0.5) * geometry.size.width), y: -6 - geometry.size.height/2)
                            
                            GraphEndpointPath(x: self.lastPointPosition).stroke(
                                style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round)
                            )
                                .foregroundColor(.white)
                                .frame(height: self.graphHeight)
                        }
                        
                        Group {
                            Group {
                                HStack(alignment: .center) {
                                    Spacer()
                                    Text("End of Term")
                                    Image(systemName: "circle.fill")
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            .frame(width: 140)
                            .offset(x: -70 + 5.5 + ((1.0 - 0.5) * geometry.size.width), y: -6 - geometry.size.height/2)
                            
                            GraphEndpointPath(x: 1.0).stroke(
                                style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round)
                            )
                                .foregroundColor(.red)
                                .frame(height: self.graphHeight)
                        }
                    }
                }
                .frame(height: graphHeight)
            }
            // X-Axis labels
            HStack {
                Spacer()
                    .frame(width: 40)
                ForEach(0 ..< 4) { num in
                    if num != 0 { Spacer() }
                    Text("x1")
                        .font(.subheadline)
                        .opacity(0.5)
                }
            }
            .frame(height: 20)
        }
    }
}
