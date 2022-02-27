//
//  DiningLoginNavigationView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/4/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningLoginNavigationView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            DiningLoginViewSwiftUI(navigationViewInstance: self)
                .navigationBarTitle(Text("Login"), displayMode: .inline)
                                .navigationBarItems(trailing: Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Cancel")
                                })
        }
    }
}
