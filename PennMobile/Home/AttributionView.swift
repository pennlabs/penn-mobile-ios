//
//  AttributionView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 3/1/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

struct AttributionView: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("Made with")
                .foregroundStyle(.secondary)
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
            Text("by")
                .foregroundStyle(.secondary)
            Link("Penn Labs", destination: URL(string: "https://pennlabs.org")!)
                .fontWeight(.semibold)
                .tint(.blue)
        }
        .font(.footnote)
        .padding(.top, 32)
    }
}

#Preview {
    AttributionView()
}
