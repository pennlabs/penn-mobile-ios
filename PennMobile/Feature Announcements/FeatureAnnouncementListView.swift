//
//  FeatureAnnouncementListView.swift
//  PennMobile
//
//  Created by Grace Li on 3/24/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

struct FeatureAnnouncementListView: View {
    let newFeatures: [NewFeature]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(Image(systemName: "bell.fill")) NEW FEATURES")
                .foregroundStyle(.labelPrimary)
                .opacity(0.7)
                .font(.caption)
                .padding(.bottom, 2)
            
            ForEach(newFeatures, id: \.id) { newFeature in
                if let featureId = newFeature.feature,
                   let appFeature = features.first(where: { $0.id == featureId }) {
                    NavigationLink(destination: appFeature.content) {
                        FeatureAnnouncementView(feature: newFeature)
                    }
                    .buttonStyle(.plain)
                } else {
                    FeatureAnnouncementView(feature: newFeature)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

