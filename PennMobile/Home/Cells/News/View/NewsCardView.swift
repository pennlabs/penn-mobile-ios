//
//  NewsCardView.swift
//  PennMobile
//
//  Created by Jacky on 2/9/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//


// MARK: - based on Anthony's NewsCardView originally in HomeCardView, moved here so grouping of news makes more sense

import SwiftUI
import SwiftSoup
import Kingfisher

struct NewsCardView: View {
    
    var article: NewsArticle
    
    var abstract: String? {
        try? SwiftSoup.parse(article.abstract).text()
    }
    
    var body: some View {
        NavigationLink {
            NewsDetailView(article: article)
                .navigationTitle(Text("News"))
        } label: {
            GenericPostCardView(
                icon: Image(systemName: "newspaper"),
                source: "The Daily Pennsylvanian",
                title: article.headline,
                description: abstract,
                imageURL: URL(string: article.dominantMedia.imageUrl),
                dateLabel: "\(article.published_at)"
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
