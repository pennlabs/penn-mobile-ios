//
//  GSRRoomLabelsView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRRoomLabelsView: View {
    let rooms: [GSRRoom]
    let width: CGFloat
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 48) {
            ForEach(rooms) { room in
                Text(room.roomNameShort)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding(4)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.background)
                    }
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .frame(width: width, height: 60)
                    .accessibilityHidden(true)
            }
        }
    }
}
