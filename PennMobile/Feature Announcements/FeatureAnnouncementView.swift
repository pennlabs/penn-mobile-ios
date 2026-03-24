//
//  FeatureAnnouncementView.swift
//  PennMobile
//
//  Created by Grace Li on 2/15/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct FeatureAnnouncementView: View {
    let feature: NewFeature

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let url = URL(string: feature.imageUrl), !feature.imageUrl.isEmpty {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack() {
                    Text(feature.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("v\(feature.version)")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                Text(feature.blurb)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.labelSecondary)
                    .multilineTextAlignment(.leading)
            }

            
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    HomeCardView {
        FeatureAnnouncementView(feature: NewFeature(
            id: "preview",
            title: "Fitness",
            blurb: "feature test test test test test test test",
            feature: .fitness,
            imageUrl: "https://images.ctfassets.net/8urtyqugdt2l/1oIrMoqckYTE96ekt5ECyT/51471e1e09c39541c1564bc164bd9b06/desktop-how-often-to-go-to-the-gym.jpg",
            version: "2.3.1"
        ))
    }
}
