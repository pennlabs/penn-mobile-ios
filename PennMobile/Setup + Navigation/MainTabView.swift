//
//  MainTabView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    @Published var currentTab = "Home"
}

struct MainTabView: View {
    @ObservedObject var mainTabViewCoordinator = MainTabViewCoordinator()
    @StateObject private var sublettingViewModel = SublettingViewModel()
    @State var tabBarFeatures = UserDefaults.standard.getTabBarFeatureIdentifiers()
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        TabView(selection: $navigationManager.currentTab) {
            HomeView<StandardHomeViewModel>()
                .tabItem {
                    Label("Home", image: "Home_Grey")
                }
                .tag("Home")
            
            ForEach(tabBarFeatures, id: \.self) { identifier in
                let feature = features.first(where: { $0.id == identifier })!
                
                NavigationStack(path: $navigationManager.path) {
                    feature.content
                }
                .environmentObject(sublettingViewModel)
                .environmentObject(navigationManager)
                .id(identifier)
                .tabItem {
                    switch feature.image {
                    case .app(let image):
                        Label(feature.shortName, image: image)
                    case .system(let image):
                        Label(feature.shortName, systemImage: image)
                    }
                }
                .tag(identifier.rawValue)
            }
            
            MoreView(features: features.filter { !tabBarFeatures.contains($0.id) })
                .tabItem {
                    Label("More", image: "More_Grey")
                }
                .tag("More")
        }
        .id(tabBarFeatures)
        .sheet(isPresented: $mainTabViewCoordinator.isConfiguringTabs, content: {
            PreferencesView()
                .presentationDragIndicator(.visible)
        })
        .onAppear {
            UserDefaults.standard.restoreCookies()
            
            // Fetch transaction data at least once a week, starting on Sundays
            if shouldFetchTransactions() {
                if UserDefaults.standard.isAuthedIn() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        PennCashNetworkManager.instance.getTransactionHistory { data in
                            if let data = data, let str = String(bytes: data, encoding: .utf8) {
                                UserDBManager.shared.saveTransactionData(csvStr: str)
                                UserDefaults.standard.setLastTransactionRequest()
                            }
                        }
                    }
                }
            }

            UserDBManager.shared.getWhartonStatus { result in
                if let isWharton = try? result.get() {
                    UserDefaults.standard.set(isInWharton: isWharton)
                }
            }

            // Send saved unsent events
            FeedAnalyticsManager.shared.sendSavedEvents()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            tabBarFeatures = UserDefaults.standard.getTabBarFeatureIdentifiers()
        }
        .environmentObject(mainTabViewCoordinator)
    }
    
    func shouldFetchTransactions() -> Bool {
        if !Account.isLoggedIn || !UserDefaults.standard.hasDiningPlan() {
            // User is not logged in or does not have a dining plan
            return false
        }

        guard let lastTransactionRequest = UserDefaults.standard.getLastTransactionRequest() else {
            // No transactions fetched yet, so return false
            return true
        }

        let now = Date()
        let diffInDays = Calendar.current.dateComponents([.day], from: lastTransactionRequest, to: now).day
        if let diff = diffInDays, diff >= 7 {
            // More than a week since last update
            return true
        } else {
            // Return true if today is Sunday and transactions have not yet been fetched today
            return now.integerDayOfWeek == 0 && !lastTransactionRequest.isToday
        }
    }
}
