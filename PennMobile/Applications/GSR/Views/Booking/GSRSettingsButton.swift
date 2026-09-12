//
//  GSRSettingsButton.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRSettingsButton: View {
    @Binding var showFullyUnavailableRooms: Bool
    @State private var isShowingSettings = false
    
    var body: some View {
        Button {
            isShowingSettings = true
        } label: {
            Image(systemName: "gearshape")
                .accessibilityLabel("Settings")
        }
        .popover(isPresented: $isShowingSettings, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
            Toggle("Show Unavailable Rooms", isOn: $showFullyUnavailableRooms)
                .padding()
                .presentationCompactAdaptation(.popover)
        }
    }
}
