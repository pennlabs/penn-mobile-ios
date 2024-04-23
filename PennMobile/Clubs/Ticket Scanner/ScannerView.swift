//
//  ScannerView.swift
//  PennMobile
//
//  Created by Anthony Li on 4/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct ScannerView: View {
    @StateObject var viewModel = ScannerViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ScannerViewfinder(session: viewModel.captureSession)
                    .overlay {
                        Rectangle()
                            .fill(LinearGradient(colors: [.black.opacity(0.7), .black.opacity(0)], startPoint: .top, endPoint: .bottom))
                            .frame(height: proxy.safeAreaInsets.top * 1.2)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .allowsHitTesting(false)
                    }
                    .overlay(alignment: .bottom) {
                        HStack {
                            Image(systemName: "viewfinder")
                            Text("Ready")
                        }
                        .fontWeight(.bold)
                        .font(.title2)
                        .textCase(.uppercase)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(.rect(cornerRadii: .init(topLeading: 24, topTrailing: 24)))
                    }
                
                Text("Scan a ticket in the viewfinder.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding()
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
    }
}
