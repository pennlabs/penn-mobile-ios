//
//  GSRRoomAvailabilityRow.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRRoomAvailabilityRow: View {
    let room: GSRRoom
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    
    func handleGesture(slot: GSRTimeSlot, room: GSRRoom) {
        do {
            try vm.handleTimeslotGesture(slot: slot, room: room)
        } catch {
            presentToast(.init(message: "\(error.localizedDescription)"))
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(vm.getRelevantAvailability(room: room), id: \.self) { slot in
                let isSelected = !vm.selectedTimeslots.filter({ $0.1.hashValue == slot.hashValue }).isEmpty
                let timeStr: String = slot.startTime.formatted(date: .omitted, time: .shortened)
                
                let valueDescription = if isSelected {
                    "Chosen"
                } else if slot.isAvailable {
                    "Free"
                } else {
                    "Unavailable"
                }
                
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundStyle(isSelected ? Color("gsrBlue") : slot.color)
                        .overlay {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                            }
                        }
                        .overlay {
                            if !slot.isAvailable {
                               UnavailableTextureOverlay()
                           }
                        }
                }
                .accessibilityElement()
                .accessibilityLabel(Text("\(timeStr) in \(room.roomNameShort)"))
                .accessibilityValue(valueDescription)
                .accessibilityAddTraits(.isToggle)
                .onTapGesture {
                    handleGesture(slot: slot, room: room)
                }
                .disabled(!slot.isAvailable)
                .frame(width: 80, height: 60)
            }
        }
    }
}
