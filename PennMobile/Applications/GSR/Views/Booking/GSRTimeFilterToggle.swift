//
//  GSRTimeFilterToggle.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRTimeFilterToggle: View {
    let time: Date
    let isActive: Bool
    let hasAvailability: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(time.gsrTimeString)
            .font(.callout)
            .multilineTextAlignment(.center)
            .foregroundStyle(isActive ? .white : .primary)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(isActive ? Color("gsrBlue") : hasAvailability ? Color("gsrAvailable") : Color("gsrUnavailable"))
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onTap()
            }
            .frame(width: GSRTimeSlotCell.width)
            .accessibilityElement()
            .disabled(!hasAvailability)
            .accessibilityLabel("Filter for \(time.gsrTimeString)")
            .accessibilityValue(hasAvailability ? (isActive ? "On" : "Off") : "No rooms available")
            .accessibilityAddTraits(.isToggle)
    }
}
