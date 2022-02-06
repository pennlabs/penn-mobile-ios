//
//  DiningLoginNavigationView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/4/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningLoginNavigationView: View {
    @Binding var showSheetView: Bool
//    @Binding var
    var body: some View {
        NavigationView {
            DiningLoginViewSwiftUI(navigationViewInstance: self)
                .navigationBarTitle(Text("Login"), displayMode: .inline)
                                .navigationBarItems(trailing: Button(action: {
                                    self.showSheetView = false
                                }) {
                                    Text("Cancel")
                                })
        }
    }
}
