//
//  ScannerView.swift
//  PennMobile
//
//  Created by Anthony Li on 4/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject var viewModel = ScannerViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ZStack {
                    ScannerViewfinder()
                    Canvas { (context, _) in
                        guard let previewLayer = viewModel.previewLayer else {
                            return
                        }
                        
                        func transform(_ point: CGPoint) -> CGPoint {
                            previewLayer.layerPointConverted(fromCaptureDevicePoint: .init(x: point.x, y: 1 - point.y))
                        }
                        
                        for barcode in viewModel.barcodes {
                            let path = Path { path in
                                path.move(to: transform(barcode.observation.topLeft))
                                path.addLine(to: transform(barcode.observation.topRight))
                                path.addLine(to: transform(barcode.observation.bottomRight))
                                path.addLine(to: transform(barcode.observation.bottomLeft))
                                path.closeSubpath()
                            }
                            
                            switch barcode.status {
                            case .active:
                                context.fill(path, with: .color(.blue.opacity(0.3)))
                                context.stroke(path, with: .color(.blue), style: .init(lineWidth: 10, lineJoin: .round))
                            case .pending:
                                context.stroke(path, with: .color(.white), style: .init(lineWidth: 10, lineJoin: .round))
                            case .alreadyScanned:
                                context.stroke(path, with: .color(.gray), style: .init(lineWidth: 10, lineJoin: .round))
                            }
                        }
                    }
                }
                .overlay {
                    Rectangle()
                        .fill(LinearGradient(colors: [.black.opacity(0.7), .black.opacity(0)], startPoint: .top, endPoint: .bottom))
                        .frame(height: proxy.safeAreaInsets.top * 1.2)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .bottom) {
                    HStack {
                        Image(systemName: viewModel.scannerState.label.icon)
                        Text(viewModel.scannerState.label.title)
                    }
                    .fontWeight(.bold)
                    .font(.title2)
                    .textCase(.uppercase)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.scannerState.label.background)
                    .foregroundStyle(viewModel.scannerState.label.foreground)
                    .clipShape(.rect(cornerRadii: .init(topLeading: 24, topTrailing: 24)))
                }
                
                ScannerStatusDetailView()
                    .frame(height: 240)
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                viewModel.setup()
            }
            .onDisappear {
                viewModel.destroy()
            }
        }
        .environmentObject(viewModel)
    }
}

struct ScannerStatusDetailView: View {
    @EnvironmentObject var viewModel: ScannerViewModel
    
    var body: some View {
        Text("Scan a ticket in the viewfinder.")
            .font(.title3)
            .foregroundStyle(.secondary)
            .padding()
    }
}
