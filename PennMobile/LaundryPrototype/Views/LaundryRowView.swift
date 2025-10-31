//
//  LaundryRowView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/20/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//


import SwiftUI

struct LaundryRowView: View {
    
    let hall: LaundryHallInfo
    let isSelected: Bool
    let canSelect: Bool
    let toggle: () -> Void
    
    var body: some View {
        HStack {
            Text(hall.name)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
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

#Preview {
    LaundryRowView(hall: LaundryHallInfo(name: "Penn Labs", hallId: 1, location: "Huntsman"), isSelected: true, canSelect: true) {}
}
