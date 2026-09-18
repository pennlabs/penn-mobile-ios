//
//  GSRTimeSlotDividersView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRTimeSlotDividersView: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: GSRTimeSlotCell.width - 1) {
            ForEach(0..<count, id: \.self) { _ in
                VerticalLine()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color(UIColor.systemGray))
                    .frame(width: 1)
            }
        }
    }
}
