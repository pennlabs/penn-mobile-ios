//
//  GSRReservationViewHelpers.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

// MARK: - Button Style Helper

enum GSRButtonStyle {
    case blueFilled
    case redOutline
    case whiteOutline
}

extension View {
    func calendarButton(style: GSRButtonStyle) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .padding()
            .frame(maxWidth: .infinity)
            .background(style == .blueFilled ? Color.blue : style == .redOutline ? Color.baseRed.opacity(0.1) : Color.white)
            .foregroundColor(style == .blueFilled ? .white : style == .redOutline ? .baseRed : .black)
            .overlay(style == .whiteOutline ? RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1) : nil)
            .cornerRadius(10)
    }

    func detailChip() -> some View {
        self
            .font(.system(size: 18, weight: .medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
    }
}
