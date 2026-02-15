//
//  LaundryRoomDisplayView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/26/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct LaundryRoomDisplayView: View {
    
    @EnvironmentObject var laundryViewModel: LaundryViewModel
    let hallId: Int
    let room: LaundryRoom
    
    @Environment(\.presentToast) var presentToast
    
    func createMachineView(room: LaundryRoom, type: MachineDetail.MachineType) -> some View {
        HStack(spacing: 16) {
            ForEach(room.machines.details, id: \.id) { detail in
                if detail.type == type {
                    Button {
                        handleMachineToggle(detail: detail, room: room)
                    } label: {
                        MachineView(detail: detail)
                            .overlay(alignment: .topTrailing) {
                                if laundryViewModel.isAlarmActive(for: detail) {
                                    Image(systemName: "bell.fill")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(.yellow)
                                        .accessibilityLabel("Alarm Active")
                                }
                            }
                    }
                    .accessibilityHint(Text("Tap to toggle machine alarm"))
                }
            }
        }
    }
    
    func handleMachineToggle(detail: MachineDetail, room: LaundryRoom) {
        Task {
            do {
                try await laundryViewModel.toggleMachineAlarm(machine: detail, hallName: room.hallName)
            } catch {
                presentToast(.init(message: "\(error.localizedDescription)"))
            }
        }
    }
    
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
                createMachineView(room: room, type: .washer)
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
                createMachineView(room: room, type: .dryer)
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
