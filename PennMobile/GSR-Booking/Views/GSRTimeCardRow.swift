//
//  GSRTimeCardRow.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRTimeCardRow: View {
    @EnvironmentObject var vm: GSRViewModel
    var body: some View {
        let relevantRooms = vm.roomsAtSelectedLocation.filter {
            vm.settings.shouldShowFullyUnavailableRooms || $0.availability.contains(where: { $0.isAvailable })
        }
        
        if let first = relevantRooms.first {
            HStack(spacing: 0) {
                let avail = vm.getRelevantAvailability()
                if let firstSlot = avail.first {
                    Text(firstSlot.startTime.gsrTimeString)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(vm.sortedStartTime.contains(where: { $0 == firstSlot.startTime }) ? .white : .primary)
                        .padding(4)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(vm.sortedStartTime.contains(where: { $0 == firstSlot.startTime }) ? Color("gsrBlue") : vm.roomsAtSelectedLocation.hasAvailableAt(firstSlot.startTime) ? Color("gsrAvailable") : Color("gsrUnavailable"))
                        }
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.3)) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                vm.handleSortAction(to: firstSlot.startTime)
                            }
                        }
                        .frame(width: 80)
                    ForEach(avail, id: \.self) { slot in
                        Text(slot.endTime.gsrTimeString)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(vm.sortedStartTime.contains(where: { $0 == slot.endTime }) ? .white : .primary)
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(vm.sortedStartTime.contains(where: { $0 == slot.endTime }) ? Color("gsrBlue") : vm.roomsAtSelectedLocation.hasAvailableAt(slot.endTime) ? Color("gsrAvailable") : Color("gsrUnavailable"))
                            }
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.3)) {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    vm.handleSortAction(to: slot.endTime)
                                }
                            }
                            .frame(width: 80)
                    }
                }
            }
        }
        
    }
}
