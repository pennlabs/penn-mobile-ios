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
    @State var selectedSlots: [GSRTimeSlot] = []
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(room.availability, id: \.self) { slot in
                Rectangle()
                    .frame(width: 80, height: 42)
                    .foregroundStyle(selectedSlots.filter({ $0.hashValue == slot.hashValue }).isEmpty ? slot.color : Color("gsrBlue"))
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2)) {
                            handleSelection(slot)
                        }
                    }
            }
        }
        .clipShape(.rect(cornerRadius: 4))
    }
    
    func handleSelection(_ slot: GSRTimeSlot) {
        // Remove from selection on click idk just basic logic
        if selectedSlots.contains(where: { $0.hashValue == slot.hashValue}) {
            selectedSlots.removeAll(where: { $0.hashValue == slot.hashValue})
            return
        }
        
        if slot.isAvailable {
            selectedSlots.append(slot)
            return
        }
    }
}


#Preview {
    let room = GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ])
    GSRRoomAvailabilityRow(room: room)
}
