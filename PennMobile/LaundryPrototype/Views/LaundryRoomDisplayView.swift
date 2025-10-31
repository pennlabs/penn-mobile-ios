//
//  LaundryRoomDisplayView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/26/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct LaundryRoomDisplayView: View {
    
    @EnvironmentObject var laundryViewModel: LaundryViewModel
    let hallId: Int
    let room: LaundryRoom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(room.location.uppercased())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Text(room.hallName)
                    .font(.title3)
                    .bold()
                Spacer()
                if laundryViewModel.isSelected(hallId) {
                    Button(action: {
                        laundryViewModel.removeSelectedHall(hallId)
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .bold()
                    }
                }
            }
            Divider()
            HStack {
                Text("Washers")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(room.machines.washers.open) out of \(room.machines.washers.open + room.machines.washers.running) open")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .bold()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(room.machines.details, id: \.id) { detail in
                        if detail.type == .washer {
                            MachineView(detail: detail)
                        }
                    }
                }
            }
            HStack {
                Text("Dryers")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(room.machines.dryers.open) out of \(room.machines.dryers.open + room.machines.dryers.running) open")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .bold()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(room.machines.details, id: \.id) { detail in
                        if detail.type == .dryer {
                            MachineView(detail: detail)
                        }
                    }
                }
            }
            HStack {
                Text("Popular Times")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Date.currentDayOfWeek)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .bold()
            }
        }
    }
}
