//
//  DiningVenueView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 9/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

@available(iOS 14, *)
struct DiningVenueView: View {
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI

    // Hack to deselect cells after popping navigation view
    // Will be removed once SwiftUI is Fixed
    @State private var selectedItem: String?
    @State private var listViewId = UUID()
    var body: some View {
        List {
            Section(header: CustomHeader(name: "Dining Balance", refreshButton: true), content: {
                Section(header: DiningViewHeader(), content: {})
            })

            ForEach(diningVM.ordering, id: \.self) { venueType in
                Section(header: CustomHeader(name: venueType.fullDisplayName)) {
                    ForEach(diningVM.diningVenues[venueType] ?? []) { venue in
                        NavigationLink(destination: DiningVenueDetailView(for: venue).environmentObject(diningVM), tag: "\(venue.id)", selection: $selectedItem) {
                            DiningVenueRow(for: venue)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.uiBackground))
        // Hack to deselect items
        .id(listViewId)
        .onAppear {
            diningVM.refreshVenues()
            diningVM.refreshBalance()
            if selectedItem != nil {
                selectedItem = nil
                listViewId = UUID()
            }
        }
        .listStyle(.plain)
    }
}

struct CustomHeader: View {

    let name: String
    var refreshButton = false
    @State var alertIsShowing = false
    @State var alertAccepted = false
    @Environment(\.presentationMode) var presentationMode
    func showCorrectAlert () -> Alert {
        if !Account.isLoggedIn {
            return Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok")))
        } else {
            return Alert(title: Text("\"Penn Mobile\" requires you to login to Campus Express to use this feature."),
                         message: Text("\(Account.isLoggedIn ? "" : "It is recommended you login first on the More tab. ")Would you like to continue to campus express?"),
                         primaryButton: .default(Text("Continue"), action: {alertAccepted = true}),
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
                    guard KeychainAccessible.instance.getDiningToken() != nil, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() > diningExpiration else {
                        alertIsShowing = true
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
        .sheet(isPresented: $alertAccepted) {
            DiningLoginNavigationView(showSheetView: self.$alertAccepted)
        }
        .alert(isPresented: $alertIsShowing) {
            showCorrectAlert()
        }
    }
}
