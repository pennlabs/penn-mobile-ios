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
    
    var body: some View {
        Group {
            switch viewModel.data {
            case .none:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                                showTitle = minY <= 16
                                            }
                                        })
                                    
                                    if let splashText {
                                        HStack(alignment: .top) {
                                            Text(splashText)
                                                .fontWeight(.medium)
                                                .opacity(0.7)
                                        }
                                    }
                                }
                                .offset(y: -16)
                                .padding(.bottom)
                                .multilineTextAlignment(.center)
                                
                                data.content(for: context.date)
                                    .frame(maxWidth: 480)
                                    .frame(maxWidth: .infinity)
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
                        try? await viewModel.fetchData(force: true)
                    }
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
                            try? await viewModel.fetchData(force: true)
                        }
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onAppear {
            Task {
                try? await viewModel.fetchData(force: false)
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
