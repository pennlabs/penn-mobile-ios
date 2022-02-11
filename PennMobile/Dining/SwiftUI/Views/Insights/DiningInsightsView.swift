//
//  DiningInsightsView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 9/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
struct DiningInsightsView: View {

    @EnvironmentObject var diningVM: DiningViewModelSwiftUI

    @Binding var pickerIndex: Int
    @State var isPresentingLoginSheet = false
    @State var loginFailure = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView {
                    VStack {
                        VStack {
                            HStack {
                                if self.diningVM.diningInsights?.diningDollars != nil {
                                    DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "dollarsign.circle.fill"), balance: self.diningVM.diningInsights!.diningDollars!, specifier: "%.2f", color: .green)
                                }

                                if self.diningVM.diningInsights?.swipes != nil {
                                    DiningBalanceView(description: "Swipes", image: Image(systemName: "creditcard.fill"), balance: Double(self.diningVM.diningInsights!.swipes!), specifier: "%g", color: .blue)
                                }
                            }.padding(.bottom)

                            HStack {
                                if self.diningVM.diningInsights?.guestSwipes != nil {
                                    DiningBalanceView(description: "Guest Swipes", image: Image(systemName: "creditcard.fill"), balance: Double(self.diningVM.diningInsights!.guestSwipes!), specifier: "%g", color: .purple)
                                }

                                BlankDiningBalanceView()
                            }.padding(.bottom)
                        }

                        if self.diningVM.diningInsights?.cards.predictionsGraphSwipes != nil {
                            CardView { PredictionsGraphView(config: self.diningVM.diningInsights!.cards.predictionsGraphSwipes!) }
                                .padding(.bottom)
                        }

                        if self.diningVM.diningInsights?.cards.predictionsGraphDollars != nil {
                            CardView { PredictionsGraphView(config: self.diningVM.diningInsights!.cards.predictionsGraphDollars!) }
                                .padding(.bottom)
                        }

                        if self.diningVM.diningInsights?.cards.recentTransactions != nil {
                            CardView { RecentTransactionsView(config: self.diningVM.diningInsights!.cards.recentTransactions!) }
                                .padding(.bottom)
                        }

                        if self.diningVM.diningInsights?.cards.frequentLocations != nil {
                            CardView { FrequentLocationsView(config: self.diningVM.diningInsights!.cards.frequentLocations!) }
                                .padding(.bottom)
                        }

                        if self.diningVM.diningInsights?.cards.dailyAverage != nil {
                            CardView { DailyAverageView(config: self.diningVM.diningInsights!.cards.dailyAverage!) }
                                .padding(.bottom)
                        }

                    }
                    .padding()
                    .frame(width: geo.size.width)
                }
                .onAppear(perform: {
                    diningVM.refreshInsights()
                })
                .alert(isPresented: .constant(!Account.isLoggedIn)) {
                    Alert(title: Text("Login Error"), message: Text("Please Login to Use this Feature"),
                          primaryButton: .default(Text("Login")) {
                            self.isPresentingLoginSheet.toggle()
                        }, secondaryButton: .cancel {
                            self.pickerIndex = 0
                        })
                }
                .sheet(isPresented: self.$isPresentingLoginSheet) {
                    LabsLoginControllerSwiftUI(isShowing: self.$isPresentingLoginSheet, loginFailure: self.$loginFailure, handleError: { self.pickerIndex = 0 })
                        .environmentObject(diningVM)
                }

                // Ad-hoc method to adding acitivity indicator
                // Will be replaced using Progress View after iOS 14 release
                ActivityIndicatorView(animating: self.$diningVM.diningInsightsIsLoading, style: .large)
                    .alert(isPresented: self.$loginFailure) {
                        Alert(title: Text("Login Failure"), message: Text("Login failed please try again later"), dismissButton: .default(Text("Do something")))
                    }
            }

        }
    }
}
