//
//  HomeView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct HomeView<Model: HomeViewModel>: View {
    @State var showTitle = false
    @State var splashText: String?
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: Model
    @EnvironmentObject var bannerViewModel: BannerViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    var dateFormatStyle: Date.FormatStyle {
        Date.FormatStyle()
            .weekday()
            .month(.wide)
            .day()
    }
    
    var body: some View {
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
                                    Color.clear.onChange(of: minY) {
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
                        
                        if FeatureFlags.testFeatureFlag {
                            Text("The test feature flag is enabled!")
                                .padding(.bottom)
                        }
                        
                        if bannerViewModel.showBanners {
                            BannerView()
                                .frame(maxWidth: .infinity)
                                .frame(width: 0)
                                .padding(.bottom)
                        }
                        
                        viewModel.data.content(for: context.date)
                            .frame(maxWidth: 480)
                            .frame(maxWidth: .infinity)
                        
                        if bannerViewModel.showBanners {
                            BannerView()
                                .frame(maxWidth: .infinity)
                                .frame(width: 0)
                                .padding(.top)
                        }
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
                        chooseSplashText(data: viewModel.data, for: context.date)
                    }
                    .onChange(of: context.date) {
                        chooseSplashText(data: viewModel.data, for: context.date)
                    }
                }
            }
            .refreshable {
                try? await viewModel.fetchData(force: true)
            }
        }.onAppear {
            (viewModel as? StandardHomeViewModel)?.navigationManager = navigationManager
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
        .environmentObject(BannerViewModel.shared)
}
