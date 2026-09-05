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
    @State var showDiningLoginView = false
    @State var showNotLoggedInAlert = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    var body: some View {
        let dollarHistory = diningAnalyticsViewModel.dollarHistory
        let swipeHistory = diningAnalyticsViewModel.swipeHistory
        VStack {
            if Account.isLoggedIn, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration {
                if dollarHistory.isEmpty && swipeHistory.isEmpty {
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
                            if let prediction = diningAnalyticsViewModel.dollarPrediction, !dollarHistory.isEmpty {
                                CardView {
                                    GraphView(type: .dollars, data: dollarHistory, start: diningAnalyticsViewModel.planStartDate ?? Date.startOfSemester, prediction: prediction)
                                    
                                }
                            }
                            // Only show swipe history view if there is data for the graph
                            if let prediction = diningAnalyticsViewModel.swipesPrediction, !swipeHistory.isEmpty {
                                CardView {
                                    GraphView(type: .swipes, data: swipeHistory, start: diningAnalyticsViewModel.planStartDate ?? Date.startOfSemester, prediction: prediction)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        }
        .task {
            guard Account.isLoggedIn else {
                showNotLoggedInAlert = true
                return
            }

            guard KeychainAccessible.instance.getDiningToken() != nil, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration else {
                showDiningLoginView = true
                return
            }
        }
        .alert("You must log in to access this feature.", isPresented: $showNotLoggedInAlert) {
            Button("Ok") { dismiss() }
        } message: {
            Text("Please login on the \"More\" tab.")
        }
        .diningLogin(isPresented: $showDiningLoginView, onCancel: { dismiss() })
        .navigationTitle("Dining Analytics")
    }
}

struct DiningAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiningAnalyticsView()
    }
}
