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
    // Reserved for future use, in case we want to roll the scanner into a larger ticketing
    // tab and need to show an onboarding hint to existing users
    @AppStorage("scannerUsedAsStandaloneFeature") var wasUsed = false
    
    @StateObject var viewModel = ScannerViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
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
                        .fill(LinearGradient(colors: [.init(UIColor.systemBackground).opacity(0.7), .init(UIColor.systemBackground).opacity(0)], startPoint: .top, endPoint: .bottom))
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
                    .padding()
                    .frame(height: 240)
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                viewModel.setup()
                wasUsed = true
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
    
    var dismissButton: some View {
        Button {
            viewModel.resetScannerState()
        } label: {
            Text("Dismiss")
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
        }
        .controlSize(.large)
        .buttonStyle(BorderedProminentButtonStyle())
    }
    
    var noTicketView: some View {
        Text("Scan a ticket in the viewfinder.")
            .font(.title3)
            .foregroundStyle(.secondary)
            .padding()
    }
    
    var loadingView: some View {
        ProgressView("Validating on Penn Clubs...")
            .controlSize(.large)
    }
    
    func errorView(for error: Error) -> some View {
        VStack {
            Text(error.localizedDescription)
                .fontWeight(.bold)
            Text("Try scanning again, or manually validate the ticket on Penn Clubs.")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            dismissButton
        }
        .multilineTextAlignment(.center)
    }
    
    func dataView(for ticket: Ticket) -> some View {
        VStack {
            Text(ticket.owner)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            
            Text(ticket.event.name)
            Text(ticket.type)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }
    
    func invalidView(for reason: ScannedTicket.InvalidReason) -> some View {
        switch reason {
        case .notFound:
            AnyView(Text("The ticket you scanned wasn't found."))
        case .malformedTicket:
            AnyView(Text("The QR code you scanned was not a Penn Clubs ticket."))
        case .badRequest(let string):
            AnyView(VStack {
                Text("The server refused to validate the ticket.")
                Text(string)
                    .foregroundStyle(.secondary)
            })
        }
    }
    
    var body: some View {
        switch viewModel.scannerState {
        case .noTicket:
            noTicketView
        case .loading:
            loadingView
        case .scanned(let ticket, _):
            switch ticket.status {
            case .valid(let data), .duplicate(let data):
                dataView(for: data)
            case .invalid(let reason):
                invalidView(for: reason)
                    .multilineTextAlignment(.center)
            }
        case .error(let error):
            errorView(for: error)
        }
    }
}

#Preview {
    ScannerView(viewModel: ScannerViewModel(mocking: .loading("")))
}
