//
//  LaundryRowView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/20/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//


import SwiftUI

struct LaundryRowView: View {
    
    // MARK: - Properties
    let hall: LaundryHallId
    let isSelected: Bool
    let canSelect: Bool
    let toggle: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(hall.name)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .opacity(canSelect ? 1 : 0.5)
        .onTapGesture {
            if canSelect { toggle() }
        }
    }
}

// MARK: - Preview
#Preview {
    LaundryRowView(hall: LaundryHallId(name: "Penn Labs", hallId: 1, location: "Huntsman"), isSelected: true, canSelect: true) {}
}
