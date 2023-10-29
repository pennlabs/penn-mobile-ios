//
//  HomeView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct HomeView<Model: HomeViewModel>: View {
    @State var showTitle = false
    @State var splashText: String?
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: Model
    
    var dateFormatStyle: Date.FormatStyle {
        Date.FormatStyle()
            .weekday()
            .month(.wide)
            .day()
    }
    
    var backgroundGradient: some View {
        LinearGradient(colors: [colorScheme == .dark ? Color("baseDarkBlue") : Color("baseLabsBlue").opacity(0.5), .clear], startPoint: .topLeading, endPoint: .center)
    }
    
    var body: some View {
        Group {
            switch viewModel.data {
            case .none:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundGradient)
                    .ignoresSafeArea()
            case .some(.success(let data)):
                NavigationStack {
                    ScrollView {
                        TimelineView(.periodic(from: Date.midnightYesterday, by: 24 * 60 * 60)) { context in
                            VStack(spacing: 0) {
                                VStack {
                                    Text("\(context.date, format: dateFormatStyle)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .background(GeometryReader { geometry in
                                            let minY = geometry.frame(in: .global).minY
                                            Color.clear.onChange(of: minY) { minY in
                                                showTitle = minY <= 32
                                            }
                                        })
                                    
                                    if let splashText {
                                        HStack(alignment: .top) {
                                            Text(splashText)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                }
                                .offset(y: -24)
                                .multilineTextAlignment(.center)
                                
                                data.content(for: context.date)
                            }
                            .padding(.bottom)
                            // Hack for forcing the navbar to always render
                            .navigationTitle(Text(showTitle ? "\(context.date, format: dateFormatStyle)" : "\u{200C}"))
                            .navigationBarTitleDisplayMode(.inline)
                            #if DEBUG
                            .toolbar {
                                if (!(viewModel is MockHomeViewModel)) {
                                    ToolbarItem(placement: .primaryAction) {
                                        NavigationLink("Debug") {
                                            HomeView<MockHomeViewModel>()
                                        }
                                    }
                                }
                            }
                            #endif
                            .onAppear {
                                chooseSplashText(data: data, for: context.date)
                            }
                            .onChange(of: context.date) { date in
                                chooseSplashText(data: data, for: date)
                            }
                        }
                    }
                    .refreshable {
                        try? await viewModel.fetchData()
                    }
                    .background(backgroundGradient.ignoresSafeArea(edges: .all))
                }
            case .some(.failure(let error)):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .foregroundStyle(.red)
                    
                    Text("Something went wrong.")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .frame(maxWidth: 400)
                    
                    Button("Retry") {
                        Task {
                            viewModel.clearData()
                            try? await viewModel.fetchData()
                        }
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(colors: [.red, .clear], startPoint: .topLeading, endPoint: .center))
                .ignoresSafeArea()
            }
        }.onAppear {
            Task {
                try? await viewModel.fetchData()
            }
        }
    }
    
    func chooseSplashText(data: HomeViewData, for date: Date) {
        splashText = data.splashText(for: date)
    }
}

#Preview {
    HomeView<MockHomeViewModel>()
        .environmentObject(MockHomeViewModel())
}
