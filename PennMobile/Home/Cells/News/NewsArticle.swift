//
//  NewsArticle.swift
//  PennMobile
//
//  Created by Josh Doman on 2/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct NewsArticle: Codable {
    let data: ArticleDataWrapper
    struct ArticleDataWrapper: Codable {
        let labsArticle: ArticleContents
        struct ArticleContents: Codable {
            let slug: String
            let headline: String
            let abstract: String
            let published_at: String
            let authors: [Author]
            let dominantMedia: DominantMedia
            let tag: String
            let content: String
            struct DominantMedia: Codable {
                let imageUrl: String
                let authors: [Author]
            }
            struct Author: Codable {
                let name: String
            }
        }
    }
}
