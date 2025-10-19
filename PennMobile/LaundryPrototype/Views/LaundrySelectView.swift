//
//  LaundrySelectView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import PennMobileShared
import SwiftUI

struct LaundrySelectView: View {
    
    @State private var searchText: String = ""
    @Binding var isShowingSelect: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Hello, World!")
            }.searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        // TODO: Implement logic.
                        isShowingSelect = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        isShowingSelect = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .navigationTitle("0/3 Chosen")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    LaundrySelectView(isShowingSelect: .constant(true))
}
