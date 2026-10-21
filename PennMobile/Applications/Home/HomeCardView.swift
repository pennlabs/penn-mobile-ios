//
//  HomeCardView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct HomeCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(Material.regular)
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
            .padding(.horizontal)
    }
}

struct GenericPostCardView: View {
    var icon: Image
    var source: String
    
    var title: String?
    var description: String?
    var imageURL: URL?
    var dateLabel: LocalizedStringKey?
    
    var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(icon) \(source)")
                    .textCase(.uppercase)
                    .fontWeight(.medium)
                if let dateLabel {
                    Spacer()
                    Text(dateLabel)
                }
            }
            .foregroundStyle(.secondary)
            .font(.caption)
            .padding(.bottom, 2)
            
            if let title {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                    .lineLimit(3)
            }
            
            if let description {
                Text(description)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        HomeCardView {
            if let imageURL {
                VStack(spacing: 0) {
                    KFImage(imageURL)
                        .resizable()
                        .scaledToFit()
                    
                    content
                        .background(alignment: .top) {
                            ZStack {
                                KFImage(imageURL)
                                    .resizable()
                                    .scaledToFill()
                                    .scaleEffect(x: 1, y: -1)
                                Rectangle().fill(.regularMaterial)
                            }
                            .drawingGroup()
                        }
                        .clipped()
                }
            } else {
                content
            }
        }
    }
}
