//
//  NewsCardView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct NewsCardView: View {
    var article: NewsArticle
    
    var body: some View {
        NavigationLink {
            NewsDetailView(article: article)
        } label: {
            GenericPostCardView(
                icon: Image(systemName: "newspaper"),
                source: "The Daily Pennsylvanian",
                title: article.headline,
                description: article.abstract.htmlToString,
                imageURL: URL(string: article.dominantMedia.imageUrl),
                dateLabel: "\(article.published_at)"
            )
        }
        .buttonStyle(.plain)
    }
}

struct NewsDetailView: View {
    var article: NewsArticle
    
    var byline: String {
        let authors = article.authors.map(\.name).joined(separator: ", ")
        return authors.isEmpty ? article.published_at : "\(authors) | \(article.published_at)"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.headline)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(byline)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    KFImage(URL(string: article.dominantMedia.imageUrl))
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 8))
                    Text(article.dominantMedia.authors.map(\.name).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(article.content.htmlToString)
                    .font(.body)
                
                VStack(spacing: 8) {
                    Image("dpPlusLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                    Link("Read more on DP+", destination: URL(string: "itms-apps://apple.com/app/id1550818171")!)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            .padding()
        }
        .navigationTitle("News")
        .navigationBarTitleDisplayMode(.inline)
    }
}
