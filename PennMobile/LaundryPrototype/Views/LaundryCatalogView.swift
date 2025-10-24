//
//  LaundryCatalogView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/24/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct LaundryCatalogView: View {
    
    @EnvironmentObject var laundryViewModel: LaundryViewModel
    @Binding var tempSelectedHallIds: Set<Int>
    @Binding var searchText: String
    
    private var groupedHalls: [String: [LaundryHallId]] {
        guard case let .success(halls) = laundryViewModel.laundryHallIds else { return [:] }
        
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
    
    var body: some View {
        switch laundryViewModel.laundryHallIds {
        case .loading:
            ProgressView("Loading laundry halls...")
        case .failure(let error):
            VStack(spacing: 8) {
                Text("Failed to load halls")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.caption)
                Button("Retry") {
                    Task { await laundryViewModel.loadLaundryHalls() }
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
                            let canSelect = isSelected || tempSelectedHallIds.count < laundryViewModel.maxSelection
                            
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
