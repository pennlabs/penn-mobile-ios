//
//  DiningAnalyticsView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/6/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI
import PennSharedCode

struct DiningAnalyticsView: View {
    @EnvironmentObject var diningAnalyticsViewModel: DiningAnalyticsViewModel
    @State var showMissingDiningTokenAlert = false
    @State var showDiningLoginView = false
    @State var notLoggedInAlertShowing = false
    @Environment(\.presentationMode) var presentationMode
    func showCorrectAlert () -> Alert {
        if !Account.isLoggedIn {
            return Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok"), action: { presentationMode.wrappedValue.dismiss() }))
        } else {
            return Alert(title: Text("\"Penn Mobile\" requires you to login to Campus Express to use this feature."),
                         message: Text("Would you like to continue to campus express?"),
                         primaryButton: .default(Text("Continue"), action: {showDiningLoginView = true}),
                         secondaryButton: .cancel({ presentationMode.wrappedValue.dismiss() }))
        }
    }
    var body: some View {
        if #available(iOS 16.0, *) {
            let dollarHistory = $diningAnalyticsViewModel.dollarHistory
            let swipeHistory = $diningAnalyticsViewModel.swipeHistory
            HStack {
                if Account.isLoggedIn, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration {
                    if dollarHistory.wrappedValue.isEmpty && swipeHistory.wrappedValue.isEmpty {
                        ZStack {
                            Image("DiningAnalyticsBackground")
                                .resizable()
                                .ignoresSafeArea()
                            Text("No Dining\nPlan Found\n ")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 48, weight: .regular))
                                .foregroundColor(.black)
                                .opacity(0.6)
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Dining Analytics")
                                    .font(.system(size: 32))
                                    .bold()
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
        } else {
            let dollarXYHistory = Binding(
                get: {
                    getSmoothedData(from: diningAnalyticsViewModel.dollarHistory)
                },
                // one directional Binding, setter does not work
                set: {  _ in }
            )
            let swipeXYHistory = Binding(
                get: { getSmoothedData(from: diningAnalyticsViewModel.swipeHistory) },
                // one directional Binding, setter does not work
                set: {  _ in }
            )
            HStack {
                if Account.isLoggedIn, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration {
                    if swipeXYHistory.wrappedValue.isEmpty && dollarXYHistory.wrappedValue.isEmpty {
                        ZStack {
                            Image("DiningAnalyticsBackground")
                                .resizable()
                                .ignoresSafeArea()
                            Text("No Dining\nPlan Found\n ")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 48, weight: .regular))
                                .foregroundColor(.black)
                                .opacity(0.6)
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Dining Analytics")
                                    .font(.system(size: 32))
                                    .bold()
                                // Only show dollar history view if there is data for the graph
                                if !dollarXYHistory.wrappedValue.isEmpty {
                                    CardView {
                                        PredictionsGraphView(type: "dollars", data: dollarXYHistory, predictedZeroDate: $diningAnalyticsViewModel.dollarPredictedZeroDate, predictedSemesterEndValue: $diningAnalyticsViewModel.predictedDollarSemesterEndBalance, axisLabelsYX: $diningAnalyticsViewModel.dollarAxisLabel, slope: $diningAnalyticsViewModel.dollarSlope)
                                    }
                                }
                                // Only show swipe history view if there is data for the graph
                                if !swipeXYHistory.wrappedValue.isEmpty {
                                    CardView {
                                        PredictionsGraphView(type: "swipes", data: swipeXYHistory, predictedZeroDate: $diningAnalyticsViewModel.swipesPredictedZeroDate, predictedSemesterEndValue: $diningAnalyticsViewModel.predictedSwipesSemesterEndBalance, axisLabelsYX: $diningAnalyticsViewModel.swipeAxisLabel, slope: $diningAnalyticsViewModel.swipeSlope)
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
        }
    }
}

extension DiningAnalyticsView {
    func getSmoothedData(from trans: [DiningAnalyticsBalance]) -> [PredictionsGraphView.YXDataPoint] {
        let sos = Date.startOfSemester
        let eos = Date.endOfSemester

        let totalLength = eos.distance(to: sos)
        let maxDollarValue = trans.max(by: { $0.balance < $1.balance })?.balance ?? 1.0
        let yxPoints: [PredictionsGraphView.YXDataPoint] = trans.map { (t) -> PredictionsGraphView.YXDataPoint in
            let xPoint = t.date.distance(to: sos) / totalLength
            return PredictionsGraphView.YXDataPoint(y: CGFloat(t.balance / maxDollarValue), x: CGFloat(xPoint))
        }
        return yxPoints
    }
}

struct DiningAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiningAnalyticsView()
    }
}
