//
//  WellnessCardView.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 4/9/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

struct WellnessCardView: View {
    var body: some View {
        NavigationLink {
            WellnessView()
        } label: {
            GenericPostCardView(
                icon: Image(systemName: "brain.head.profile"),
                source: "Undergraduate Assembly",
                title: "Wellness Resources",
                description: "View an outline of various resources and support available to Penn students."
            )
        }
        .buttonStyle(.plain)
    }
}
