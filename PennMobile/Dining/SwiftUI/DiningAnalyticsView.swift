//
//  DiningAnalyticsView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/6/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningAnalyticsView: View {

    @State var showMissingDiningTokenAlert = false
    @State var showDiningLoginView = false
    @State var notLoggedInAlertShowing = false
    @Environment(\.presentationMode) var presentationMode

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

        Text("This is the dining analytics view")
            .sheet(isPresented: $showDiningLoginView) {
                DiningLoginNavigationView()
            }
            .onAppear {
                guard let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() > diningExpiration else {
                    if Account.isLoggedIn {
                        showMissingDiningTokenAlert = true
                    } else {
                        notLoggedInAlertShowing = true
                    }
                    return
                }
            }
            .alert(isPresented: $showMissingDiningTokenAlert) {
                showCorrectAlert()
            }
    }
}

struct DiningAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiningAnalyticsView()
    }
}
