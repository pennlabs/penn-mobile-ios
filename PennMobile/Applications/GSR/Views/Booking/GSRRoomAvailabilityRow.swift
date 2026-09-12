//
//  GSRRoomAvailabilityRow.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRRoomAvailabilityRow: View {
    let room: GSRRoom
    let selectedSlotIDs: Set<UUID>
    let onToggleSlot: (GSRTimeSlot, GSRRoom) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(room.availability) { slot in
                GSRTimeSlotCell(slot: slot, roomName: room.roomNameShort, isSelected: selectedSlotIDs.contains(slot.id)) {
                    onToggleSlot(slot, room)
                }
            }
        }
    }
}
