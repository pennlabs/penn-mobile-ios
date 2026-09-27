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
            switch laundryViewModel.hallUsages[hallId] {
            case .some(.loading), .none:
                ProgressView("Loading usage...")
                    .padding(.vertical, 40)
            case .some(.failure(let error)):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                    Text("Failed to load usage")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await laundryViewModel.loadLaundryHallUsage(for: hallId) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 20)
            case .some(.success(let usage)):
                if let room = usage.rooms.first {
                    LaundryRoomDisplayView(hallId: hallId, room: room)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("No room data available")
                            .font(.headline)
                        Button("Retry") {
                            Task { await laundryViewModel.loadLaundryHallUsage(for: hallId) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .padding()
    }
}
