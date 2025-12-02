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
                            .foregroundStyle(.gray)
                            .bold()
                    }
                }
            }
            Divider()
            HStack {
                Text("Washers")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(room.machines.washers.open) out of \(room.usageData.totalNumberOfWashers) open")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(room.machines.details, id: \.id) { detail in
                        if detail.type == .washer {
                            Button {
                                laundryViewModel.toggleMachineAlarm(machine: detail, hallName: room.hallName)
                            } label: {
                                MachineView(detail: detail)
                                    .overlay(alignment: .topTrailing) {
                                        if laundryViewModel.isAlarmActive(for: detail) {
                                            Image(systemName: "bell.fill")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            HStack {
                Text("Dryers")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(room.machines.dryers.open) out of \(room.usageData.totalNumberOfDryers) open")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(room.machines.details, id: \.id) { detail in
                        if detail.type == .dryer {
                            Button {
                                laundryViewModel.toggleMachineAlarm(machine: detail, hallName: room.hallName)
                            } label: {
                                MachineView(detail: detail)
                                    .overlay(alignment: .topTrailing) {
                                        if laundryViewModel.isAlarmActive(for: detail) {
                                            Image(systemName: "bell.fill")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            HStack {
                Text("Popular Times")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(Date.currentDayOfWeek)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
            }
            LaundryGraphView(usageData: room.usageData)
        }
    }
}
