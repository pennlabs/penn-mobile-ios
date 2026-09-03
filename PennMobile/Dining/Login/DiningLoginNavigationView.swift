//
//  DiningLoginNavigationView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/4/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct DiningLoginNavigationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diningAnalyticsViewModel: DiningAnalyticsViewModel

    var body: some View {
        NavigationStack {
            DiningLoginViewSwiftUI(onDismiss: { dismiss() })
                .navigationBarTitle(Text("Login"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                })
                .environmentObject(diningAnalyticsViewModel)
        }
    }
}
