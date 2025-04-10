//
//  RoomFinderSelectionPanel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 4/7/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct RoomFinderSelectionPanel: View {
    @Binding var isEnabled: Bool
    
    
    var body: some View {
        VStack {
            Spacer()
            if isEnabled {
                VStack {
                    Text("HELLO!")
                }
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 2)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            
            
            Button {
                withAnimation(.snappy(duration: 0.2)) {
                    isEnabled.toggle()
                }
            } label: {
                Label("Find me a room", systemImage: "wand.and.sparkles")
                    .font(.body)
                    .foregroundStyle(isEnabled ? Color.white : Color(UIColor.systemGray))
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(isEnabled ? Color("gsrBlue") : Color.white)
                            .shadow(radius: 2)
                    }
            }
        }
    }
}

#Preview {
    @Previewable @State var on = false
    
    RoomFinderSelectionPanel(isEnabled: $on)
}
