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
            .safari(isPresented: $showExternalLink, url: sublet.data.externalLink.flatMap { URL(string: $0) })
    }
}

#Preview {
    SubletMapView(sublet: Sublet.mock)
}
