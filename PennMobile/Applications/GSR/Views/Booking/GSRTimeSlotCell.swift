//
//  GSRTimeSlotCell.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRTimeSlotCell: View {
    static let width: CGFloat = 80
    
    let slot: GSRTimeSlot
    let roomName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private var accessibilityValue: String {
        if isSelected {
            "Chosen"
        } else if slot.isAvailable {
            "Free"
        } else {
            "Unavailable"
        }
    }
    
    var body: some View {
        Rectangle()
            .foregroundStyle(isSelected ? Color("gsrBlue") : slot.color)
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                }
            }
            .overlay {
                if !slot.isAvailable {
                    UnavailableTextureOverlay()
                }
            }
            .accessibilityElement()
            .accessibilityLabel(Text("\(slot.startTime.formatted(date: .omitted, time: .shortened)) in \(roomName)"))
            .accessibilityValue(accessibilityValue)
            .accessibilityAddTraits(.isToggle)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onTap()
            }
            .disabled(!slot.isAvailable)
            .frame(width: Self.width, height: 60)
    }
}
