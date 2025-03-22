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
    //@Environment(\.presentToast) var presentToast
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(room.availability, id: \.self) { slot in
                Rectangle()
                    .frame(width: 80, height: 42)
                    .foregroundStyle(vm.selectedTimeslots.filter({ $0.1.hashValue == slot.hashValue }).isEmpty ? slot.color : Color("gsrBlue"))
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2)) {
                            do {
                                try vm.handleTimeslotGesture(slot: slot, room: room)
                            } catch {
//                                presentToast(ToastConfiguration({
//                                    Text(error.localizedDescription)
//                                }))
                            }
                        }
                    }
            }
        }
        .clipShape(.rect(cornerRadius: 4))
    }
}


#Preview {
    let room = GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ])
    GSRRoomAvailabilityRow(room: room)
}
