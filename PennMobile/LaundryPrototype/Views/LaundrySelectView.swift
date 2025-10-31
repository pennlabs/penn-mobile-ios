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
    
    @Binding var isShowingSelect: Bool
    @State private var searchText: String = ""
    @State private var tempSelectedHallIds: Set<Int> = []
    @EnvironmentObject var laundryViewModel: LaundryViewModel
    
    private var selectionCountText: String {
        "\(min(tempSelectedHallIds.count, laundryViewModel.maxSelection))/\(laundryViewModel.maxSelection) Selected"
    }
    
    var body: some View {
        NavigationStack {
            LaundryCatalogView(
                tempSelectedHallIds: $tempSelectedHallIds, searchText: $searchText
            )
                .navigationTitle(selectionCountText)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { isShowingSelect = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            laundryViewModel.setSelectedHalls(tempSelectedHallIds)
                            isShowingSelect = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                }
                .searchable (
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search..."
                )
                .onAppear {
                    tempSelectedHallIds = laundryViewModel.currentSelectedHalls()
                }
        }
    }
}

#Preview {
    LaundrySelectView(isShowingSelect: .constant(true))
        .environmentObject(LaundryViewModel())
}
