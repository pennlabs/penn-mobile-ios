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
    
    var statusText: String? {
        switch detail.status {
        case .complete:
            return detail.timeRemaining > 0 ? "\(detail.timeRemaining)" : nil
        case .available:
            return nil
        case .inUse:
            return detail.timeRemaining > 0 ? "\(detail.timeRemaining)" : nil
        default:
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            Image(detail.status.imageName(for: detail.type))
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            if let text = statusText {
                Text(text)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(detail.status == .available ? .green : .secondary)
            }
        }
    }
}
