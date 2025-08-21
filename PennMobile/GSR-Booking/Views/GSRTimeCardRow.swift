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
                        .foregroundStyle(firstSlot.startTime == vm.sortedStartTime ? .white : .primary)
                        .padding(4)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(firstSlot.startTime == vm.sortedStartTime ? Color("gsrBlue") : vm.roomsAtSelectedLocation.hasAvailableAt(firstSlot.startTime) ? Color("gsrAvailable") : Color("gsrUnavailable"))
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
                            .foregroundStyle(slot.endTime == vm.sortedStartTime ? .white : .primary)
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(slot.endTime == vm.sortedStartTime ? Color("gsrBlue") : vm.roomsAtSelectedLocation.hasAvailableAt(slot.endTime) ? Color("gsrAvailable") : Color("gsrUnavailable"))
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
