//
//  DiningAnalyticsView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/6/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningAnalyticsView: View {

    @State var alertIsShowing = false
    @State var alertAccepted = false
    @State var notLoggedInAlertShowing = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {

        Text("This is the dining analytics view")
            .sheet(isPresented: $alertAccepted) {
                DiningLoginNavigationView(showSheetView: self.$alertAccepted)
            }
            .onAppear {
                guard let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() > diningExpiration else {
                    if Account.isLoggedIn {
                        alertIsShowing = true
                    } else {
                        notLoggedInAlertShowing = true
                    }
                    return
                }
            }
            .alert(isPresented: $alertIsShowing) {
                    Alert(title: Text("\"Penn Mobile\" requires you to login to Campus Express to use this feature."),
                          message: Text("Would you like to continue to campus express??"),
                          primaryButton: .default(Text("Continue"), action: {alertAccepted = true}),
                          secondaryButton: .cancel({ presentationMode.wrappedValue.dismiss() }))
            }
            .alert(isPresented: $notLoggedInAlertShowing) {
                Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok")))
            }
    }
}

struct DiningAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiningAnalyticsView()
    }
}
