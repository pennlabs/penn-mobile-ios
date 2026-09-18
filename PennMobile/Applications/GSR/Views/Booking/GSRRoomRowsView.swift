//
//  GSRRoomRowsView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRRoomRowsView: View {
    let rooms: [GSRRoom]
    let dividerCount: Int
    let selectedSlotIDs: Set<UUID>
    let onToggleSlot: (GSRTimeSlot, GSRRoom) -> Void
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 48) {
            ForEach(rooms) { room in
                GSRRoomAvailabilityRow(room: room, selectedSlotIDs: selectedSlotIDs, onToggleSlot: onToggleSlot)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(room.roomNameShort)
            }
            Spacer()
        }
        .accessibilityRotor("Rooms") {
            ForEach(rooms) { room in
                AccessibilityRotorEntry(room.roomNameShort, id: room.id)
            }
        }
        .overlay {
            GSRTimeSlotDividersView(count: dividerCount)
        }
        .padding(.trailing, 48)
    }
}
