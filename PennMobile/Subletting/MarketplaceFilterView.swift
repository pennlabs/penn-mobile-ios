//
//  MarketplaceFilterView.swift
//  PennMobile
//
//  Created by Jordan H on 2/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct MarketplaceFilterView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Hello, World!")
                .navigationBarTitle(Text("Filter by"), displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }, trailing: Button(action: {
                    dismiss()
                }) {
                    Text("Save")
                })
        }
    }
}

#Preview {
    MarketplaceFilterView()
}
