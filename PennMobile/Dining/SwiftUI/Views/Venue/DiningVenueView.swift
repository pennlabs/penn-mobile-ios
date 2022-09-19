//
//  DiningVenueView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 9/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningVenueView: View {
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    @StateObject var diningAnalyticsViewModel = DiningAnalyticsViewModel()

    var body: some View {
        List {
            Section(header: CustomHeader(name: "Dining Balance", refreshButton: true).environmentObject(diningAnalyticsViewModel), content: {
                Section(header: DiningViewHeader().environmentObject(diningAnalyticsViewModel), content: {})
            })

            ForEach(diningVM.ordering, id: \.self) { venueType in
                Section(header: CustomHeader(name: venueType.fullDisplayName).environmentObject(diningAnalyticsViewModel)) {
                    ForEach(diningVM.diningVenues[venueType] ?? []) { venue in
                        NavigationLink(destination: DiningVenueDetailView(for: venue).environmentObject(diningVM)) {
                            DiningVenueRow(for: venue)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .task {
            await diningVM.refreshVenues()
        }
        .onAppear {
            diningVM.refreshBalance()
        }
        .listStyle(.plain)
    }
}

struct CustomHeader: View {

    let name: String
    var refreshButton = false
    @State var didError = false
    @State var showMissingDiningTokenAlert = false
    @State var showDiningLoginView = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var diningAnalyticsViewModel: DiningAnalyticsViewModel
    func showCorrectAlert () -> Alert {
        if !Account.isLoggedIn {
            return Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok")))
        } else {
            return Alert(title: Text("\"Penn Mobile\" requires you to login to Campus Express to use this feature."),
                         message: Text("Would you like to continue to campus express?"),
                         primaryButton: .default(Text("Continue"), action: {showDiningLoginView = true}),
                         secondaryButton: .cancel({ presentationMode.wrappedValue.dismiss() }))
        }
    }

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            if refreshButton {
                Button(action: {
                    guard Account.isLoggedIn, KeychainAccessible.instance.getDiningToken() != nil, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration else {
                        print("Should show alert")
                        showMissingDiningTokenAlert = true
                        return
                    }
                    DiningViewModelSwiftUI.instance.refreshBalance()
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
            }
        }
        .padding()
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color(UIColor.uiBackground))
        // Default Text Case for Header is Caps Lock
        .textCase(nil)
        .sheet(isPresented: $showDiningLoginView) {
            DiningLoginNavigationView()
                .environmentObject(diningAnalyticsViewModel)
        }

        // Note: The Alert view is soon to be deprecated, but .alert(_:isPresented:presenting:actions:message:) is available in iOS15+
        .alert(isPresented: $showMissingDiningTokenAlert) {
            showCorrectAlert()
        }

        // iOS 15+ implementation
        /* .alert(Account.isLoggedIn ? "\"Penn Mobile\" requires you to login to Campus Express to use this feature." : "You must log in to access this feature.", isPresented: $showMissingDiningTokenAlert
        ) {
            if (!Account.isLoggedIn) {
                Button("OK") {}
            } else {
                Button("Continue") { showDiningLoginView = true }
                Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            }
        } message: {
            if (!Account.isLoggedIn) {
                Text("Please login on the \"More\" tab.")
            } else {
                Text("Would you like to continue to Campus Express?")
            }
        } */
    }
}
