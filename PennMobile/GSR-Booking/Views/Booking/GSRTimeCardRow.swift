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
    
    static let width: CGFloat = 80
    
    var body: some View {
        let isFilterActive = vm.sortedStartTime.contains(where: { $0 == time })
        let hasAvailableTimes = vm.roomsAtSelectedLocation.hasAvailableAt(time)
        let isQuickBookEdge = vm.quickBookHighlight?.lowerBound == time || vm.quickBookHighlight?.upperBound == time
        let accessibilityValue = if hasAvailableTimes {
            isFilterActive ? "On" : "Off"
        } else {
            "No rooms available"
        }

        Text(time.gsrTimeString)
            .font(.callout)
            .fontWeight(isQuickBookEdge ? .bold : .regular)
            // Bold text is wider; shrink it slightly instead of wrapping and pushing the grid down
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .multilineTextAlignment(.center)
            .foregroundStyle(isFilterActive ? .white : isQuickBookEdge ? Color("gsrBlue") : .primary)
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
            .frame(width: Self.width)
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
