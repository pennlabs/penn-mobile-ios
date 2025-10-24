//
//  LaundryRoomView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct LaundryRoomView: View {
    
    let hallId: Int
    @EnvironmentObject var laundryViewModel: LaundryViewModel
    
    var body: some View {
        VStack {
            if laundryViewModel.isSelected(hallId) {
                Button(action: {
                    laundryViewModel.removeSelectedHall(hallId)
                }) {
                    Image(systemName: "minus.circle.fill")
                }
                .buttonStyle(.bordered)
            }
            switch laundryViewModel.hallUsages[hallId] {
            case .some(.loading), .none:
                ProgressView("Loading usage...")
            case .some(.failure(let error)):
                VStack(spacing: 8) {
                    Text("Failed to load usage")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                    Button("Retry") {
                        Task { await laundryViewModel.loadLaundryHallUsage(for: hallId) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .some(.success(let usage)):
                if let first = usage.rooms.first {
                    VStack {
                        Text("Hello")
                        Text("Washers: \(first.usageData.totalNumberOfWashers)")
                        Text("Dryers: \(first.usageData.totalNumberOfDryers)")
                    }
                }
            }
        }
        .padding()
        .task(id: hallId) {
            await laundryViewModel.loadLaundryHallUsage(for: hallId)
        }
    }
}
