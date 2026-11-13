//
//  FeatureGridView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/5/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct FeatureGridView: View {
    let features: [AppFeature]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 120), alignment: .top)], spacing: 16) {
            ForEach(features) { feature in
                NavigationLink {
                    feature.content
                        .navigationTitle(Text(feature.longName))
                } label: {
                    VStack {
                        feature.image
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .padding(12)
                            .background(feature.color)
                            .clipShape(.rect(cornerRadius: 8))
                            .environment(\.colorScheme, .dark)
                        (
                            Text(feature.longName) +
                            Text("\u{00a0}\(Image(systemName: "chevron.forward"))").foregroundColor(.secondary)
                        ).font(.caption)
                    }
                }
                .tint(.primary)
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 16)
    }
}
