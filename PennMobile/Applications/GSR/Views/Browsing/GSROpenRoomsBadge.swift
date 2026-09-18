//
//  GSROpenRoomsBadge.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSROpenRoomsBadge: View {
    let openRoomCount: Int
    
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
            Text(openRoomCount == 0 ? "All currently reserved" : "\(openRoomCount) open now")
        }
        .font(.system(size: 12))
        .foregroundStyle(openRoomCount == 0 ? Color("baseRed") : Color("baseGreen"))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}
