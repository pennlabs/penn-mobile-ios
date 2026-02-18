//
//  MachineView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct MachineView: View {
    
    let detail: MachineDetail
    
    var body: some View {
        ZStack {
            Image(detail.status.imageName(for: detail.type))
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            if detail.timeRemaining > 0 {
                Text("\(detail.timeRemaining)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
