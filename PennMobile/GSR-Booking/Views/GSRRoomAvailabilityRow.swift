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
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(vm.getRelevantAvailability(room: room), id: \.self) { slot in
                let isSelected = !vm.selectedTimeslots.filter({ $0.1.hashValue == slot.hashValue }).isEmpty
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundStyle(isSelected ? Color("gsrBlue") : slot.color)
                    VStack(alignment: .center, spacing: 0) {
                        Text("\(slot.startTime.gsrTimeString)")
                            .lineLimit(1)
                        Text("to")
                            .lineLimit(1)
                        Text("\(slot.endTime.gsrTimeString)")
                            .lineLimit(1)
                    }
                    .font(.system(.body, weight: .light))
                    .foregroundStyle(isSelected ? Color.white : .primary)
                }
                .onTapGesture {
                    do {
                        try vm.handleTimeslotGesture(slot: slot, room: room)
                    } catch {
                        presentToast(ToastConfiguration({
                            Text(error.localizedDescription)
                        }))
                    }
                }
                .padding(4)
                .frame(width: 80, height: 80)
            }
        }
        .clipShape(.rect(cornerRadius: 4))
    }
}
