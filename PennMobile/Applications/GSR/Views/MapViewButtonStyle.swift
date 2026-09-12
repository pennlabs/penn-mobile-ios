//
//  MapViewButtonStyle.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct MapViewButtonStyle: ButtonStyle {
    @ViewBuilder func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
                .glassEffect(.regular.interactive(), in: .capsule)
                .contentShape(.capsule)
                .shadow(color: .black.opacity(0.12), radius: 8)
        } else {
            configuration.label
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    Capsule().stroke(.secondary)
                }
        }
    }
}
