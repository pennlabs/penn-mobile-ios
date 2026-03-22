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
        let filteredMachines = room.machines.details.filter { $0.type == type }
        return HStack(spacing: 16) {
            ForEach(filteredMachines, id: \.id) { detail in
                Button {
                    handleMachineToggle(detail: detail, room: room)
                } label: {
                    ZStack(alignment: .topTrailing) {
                        MachineView(detail: detail)
                        
                        if laundryViewModel.isAlarmActive(for: detail) {
                            Image(systemName: "bell.fill")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(.yellow)
                                .background(
                                    Circle()
                                        .fill(.black.opacity(0.5))
                                        .frame(width: 18, height: 18)
                                )
                                .offset(x: 2, y: -2)
                                .accessibilityLabel("Alarm Active")
                        } else if detail.status == .inUse && detail.timeRemaining > 0 {
                            Image(systemName: "bell")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(.white)
                                .background(
                                    Circle()
                                        .fill(.gray.opacity(0.8))
                                        .frame(width: 18, height: 18)
                                )
                                .offset(x: 2, y: -2)
                                .accessibilityLabel("Tap to set alarm")
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint(Text("Tap to toggle machine alarm"))
            }
        }
        .padding(.vertical, 4)
    }
    
    func handleMachineToggle(detail: MachineDetail, room: LaundryRoom) {
        Task {
            do {
                let wasAlarmActive = laundryViewModel.isAlarmActive(for: detail)
                try await laundryViewModel.toggleMachineAlarm(machine: detail, hallName: room.hallName)
                
                let machineType = detail.type == .washer ? "washer" : "dryer"
                let message: String
                if wasAlarmActive {
                    message = "Alarm cancelled"
                } else {
                    message = "Alarm set! You'll be notified when this \(machineType) is done."
                }
                presentToast(.init(message: String.LocalizationValue(stringLiteral: message)))
            } catch {
                presentToast(.init(message: String.LocalizationValue(stringLiteral: error.localizedDescription)))
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
