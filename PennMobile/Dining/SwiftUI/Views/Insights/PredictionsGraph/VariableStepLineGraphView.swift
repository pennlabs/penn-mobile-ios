//
//  VariableStepLineGraphView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

struct VariableStepLineGraphView: View {

    private let graphHeight: CGFloat = 160.0

    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var trimEnd: CGFloat = 0.0
    @GestureState private var dragActive = false
    @Binding var data: [PredictionsGraphView.YXDataPoint]
    var lastPointPosition: CGFloat = 0.0
    @Binding var xAxisLabels: [String]
    @Binding var yAxisLabels: [String]
    var lineColor: Color
    @Binding var predictedZeroPoint: PredictionsGraphView.YXDataPoint

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 20)

            HStack {
                // Y-Axis labels
                VStack(alignment: .leading) {
                    ForEach(yAxisLabels, id: \.self) { label in
                        if label != yAxisLabels.first { Spacer().frame(width: 40) }
                        Text(label)
                            .font(.subheadline)
                            .opacity(0.5)

                    }
                }
                .frame(width: 40, height: self.graphHeight)

                GeometryReader { geometry in
                    ZStack {

                        VariableStepGraphPath(data: self.$data).trim(from: 0, to: self.trimEnd).stroke(
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                            .foregroundColor(self.lineColor)
                            .frame(height: self.graphHeight)
                            .animation(.default)
                            .onAppear {
                                self.trimEnd = 1.0
                        }

                        PredictionSlopePath(lastDataPoint: self.data.last ?? PredictionsGraphView.YXDataPoint.init(y: 20, x: 20), predictionZeroPoint: self.predictedZeroPoint).stroke(
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
                .frame(height: self.graphHeight)

                Spacer()
                    .frame(width: 10)
            }
            // X-Axis labels
            HStack(spacing: 20) {
                Spacer()
                    .frame(width: 40)
                ForEach(xAxisLabels, id: \.self) { label in
                    if label != xAxisLabels.first { Spacer() }
                    Text(label)
                        .font(.subheadline)
                        .opacity(0.5)
                }
            }
            .frame(height: 20)
        }
    }
}
