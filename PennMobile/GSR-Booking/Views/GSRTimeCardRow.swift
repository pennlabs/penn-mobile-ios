//
//  GSRTimeCardRow.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRTimeCardFilterToggle: View {
    @EnvironmentObject var vm: GSRViewModel
    var time: Date
    
    var body: some View {
        let isFilterActive = vm.sortedStartTime.contains(where: { $0 == time })
        let hasAvailableTimes = vm.roomsAtSelectedLocation.hasAvailableAt(time)
        let accessibilityValue = if hasAvailableTimes {
            isFilterActive ? "On" : "Off"
        } else {
            "No rooms available"
        }
        
        Text(time.gsrTimeString)
            .font(.callout)
            .multilineTextAlignment(.center)
            .foregroundStyle(vm.sortedStartTime.contains(where: { $0 == time }) ? .white : .primary)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(isFilterActive ? Color("gsrBlue") : hasAvailableTimes ? Color("gsrAvailable") : Color("gsrUnavailable"))
            }
            .onTapGesture {
                withAnimation(.snappy(duration: 0.3)) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    vm.handleSortAction(to: time)
                }
            }
            .frame(width: 80)
            .accessibilityElement()
            .disabled(!hasAvailableTimes)
            .accessibilityLabel("Filter for \(time.gsrTimeString)")
            .accessibilityValue(accessibilityValue)
            .accessibilityAddTraits(.isToggle)
    }
}

struct GSRTimeCardRow: View {
    @EnvironmentObject var vm: GSRViewModel
    var body: some View {
        let relevantRooms = vm.roomsAtSelectedLocation.filter {
            vm.settings.shouldShowFullyUnavailableRooms || $0.availability.contains(where: { $0.isAvailable })
        }
        
        HStack(spacing: 0) {
            let avail = vm.getRelevantAvailability()
            if let firstSlot = avail.first {
                GSRTimeCardFilterToggle(time: firstSlot.startTime)
                ForEach(avail, id: \.self) { slot in
                    GSRTimeCardFilterToggle(time: slot.endTime)
                }
            }
        }
        
    }
}
