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
    @EnvironmentObject var viewModel: LaundryViewModel
    
    private var groupedHalls: [String: [LaundryHallId]] {
        guard case let .success(halls) = viewModel.laundryHallIds else { return [:] }
        
        let filtered = halls.filter { hall in
            searchText.isEmpty ||
            hall.name.localizedCaseInsensitiveContains(searchText) ||
            hall.location.localizedCaseInsensitiveContains(searchText)
        }
        
        return Dictionary(grouping: filtered, by: { $0.location })
    }
    
    private var sortedLocations: [String] {
        groupedHalls.keys.sorted()
    }
    
    private var selectionCountText: String {
        "\(min(tempSelectedHallIds.count, viewModel.maxSelection))/\(viewModel.maxSelection) Selected"
    }
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(selectionCountText)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { isShowingSelect = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            viewModel.setSelectedHalls(tempSelectedHallIds)
                            isShowingSelect = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                }
                .onAppear {
                    tempSelectedHallIds = viewModel.currentSelectedHalls()
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.laundryHallIds {
        case .loading:
            ProgressView("Loading laundry halls...")
        case .failure(let error):
            VStack(spacing: 8) {
                Text("Failed to load halls")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.caption)
                Button("Retry") {
                    Task { await viewModel.loadLaundryHalls() }
                }
                .buttonStyle(.borderedProminent)
            }
        case .success:
            List {
                ForEach(sortedLocations, id: \.self) { location in
                    Section(header: Text(location)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    ) {
                        ForEach(groupedHalls[location] ?? [], id: \.hallId) { hall in
                            let isSelected = tempSelectedHallIds.contains(hall.hallId)
                            let canSelect = isSelected || tempSelectedHallIds.count < viewModel.maxSelection
                            
                            LaundryRowView(
                                hall: hall,
                                isSelected: isSelected,
                                canSelect: canSelect
                            ) {
                                if isSelected {
                                    tempSelectedHallIds.remove(hall.hallId)
                                } else {
                                    tempSelectedHallIds.insert(hall.hallId)
                                }
                            }
                        }
                    }
                }
            }
            .searchable (
                text: $searchText,
                prompt: "Search..."
            )
        }
    }
}

#Preview {
    LaundrySelectView(isShowingSelect: .constant(true))
        .environmentObject(LaundryViewModel())
}
