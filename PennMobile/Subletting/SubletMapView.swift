//
//  SubletMapView.swift
//  PennMobile
//
//  Created by Jordan H on 3/3/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct SubletMapView: View {
    let sublet: Sublet
    @State var showExternalLink = false

    var body: some View {
        AddressMapView(address: sublet.address)
            .navigationTitle(sublet.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SubletDetailToolbar(sublet: sublet, showExternalLink: $showExternalLink)
                }
            }
            .sheet(isPresented: $showExternalLink) {
                WebView(url: URL(string: sublet.data.externalLink!)!)
            }
    }
}

#Preview {
    SubletMapView(sublet: Sublet.mock)
}
