//
//  DiningAnalyticsView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/6/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct DiningAnalyticsView: View {
    @EnvironmentObject var diningAnalyticsViewModel: DiningAnalyticsViewModel
    @State var showMissingDiningTokenAlert = false
    @State var showDiningLoginView = false
    @State var notLoggedInAlertShowing = false
    @State var showSettingsSheet = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    func showCorrectAlert() -> Alert {
        if !Account.isLoggedIn {
            return Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok"), action: { dismiss() }))
        } else {
            return Alert(title: Text("\"Penn Mobile\" requires you to login to Campus Express to use this feature."),
                         message: Text("Would you like to continue to campus express?"),
                         primaryButton: .default(Text("Continue"), action: {showDiningLoginView = true}),
                         secondaryButton: .cancel({ dismiss() }))
        }
    }
    var body: some View {
        let dollarHistory = $diningAnalyticsViewModel.dollarHistory
        let swipeHistory = $diningAnalyticsViewModel.swipeHistory
        VStack {
            if Account.isLoggedIn, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration {
                if dollarHistory.wrappedValue.isEmpty && swipeHistory.wrappedValue.isEmpty {
                    ZStack {
                        let image = Image("DiningAnalyticsBackground")
                            .resizable()
                            .ignoresSafeArea()

                        switch colorScheme {
                        case .dark:
                            image
                                .colorInvert()
                                .hueRotation(.degrees(180))
                                .saturation(0.8)
                                .contrast(0.8)
                        default:
                            image
                        }
                        
                        VStack(spacing: 24) {
                            Text("No Dining Plan Found")
                                .font(.system(size: 48, weight: .regular))
                            Text("Dining Analytics may not appear until the day after the semester begins.")
                        }
                        .frame(maxWidth: 280)
                        .padding(.bottom, 64)
                        .multilineTextAlignment(.center)
                        .opacity(0.6)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Only show dollar history view if there is data for the graph
                            if !dollarHistory.wrappedValue.isEmpty {
                                CardView {
                                    GraphView(type: .dollars, data: dollarHistory, predictedZeroDate: $diningAnalyticsViewModel.dollarPredictedZeroDate, predictedSemesterEndValue: $diningAnalyticsViewModel.predictedDollarSemesterEndBalance)
                                }
                            }
                            // Only show swipe history view if there is data for the graph
                            if !swipeHistory.wrappedValue.isEmpty {
                                CardView {
                                    GraphView(type: .swipes, data: swipeHistory, predictedZeroDate: $diningAnalyticsViewModel.swipesPredictedZeroDate, predictedSemesterEndValue: $diningAnalyticsViewModel.predictedSwipesSemesterEndBalance)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showSettingsSheet.toggle()
                            }) {
                                Image(systemName: "gear")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
            }
        }
        .task {
            guard Account.isLoggedIn, KeychainAccessible.instance.getDiningToken() != nil, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration else {
                showMissingDiningTokenAlert = true
                return
            }
        }
        .alert(isPresented: $showMissingDiningTokenAlert) {
            showCorrectAlert()
        }
        .sheet(isPresented: $showDiningLoginView) {
            DiningLoginNavigationView()
                .environmentObject(diningAnalyticsViewModel)
        }
        .navigationTitle("Dining Analytics")
        .sheet(isPresented: $showSettingsSheet) {
            DiningSettingsView(viewModel: diningAnalyticsViewModel)
        }
    }
}

struct DiningAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiningAnalyticsView()
    }
}
