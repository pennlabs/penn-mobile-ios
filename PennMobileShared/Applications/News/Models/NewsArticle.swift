//
//  NewsArticle.swift
//  PennMobile
//
//  Created by Josh Doman on 2/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

@dynamicMemberLookup
public struct NewsArticle: Codable, Identifiable, Sendable {
    public let data: ArticleDataWrapper
    
    public struct ArticleDataWrapper: Codable, Sendable {
        public let labsArticle: ArticleContents
        
        public struct ArticleContents: Codable, Sendable {
            public let slug: String
            public let headline: String
            public let abstract: String
            public let published_at: String
            public let authors: [Author]
            public let dominantMedia: DominantMedia
            public let tag: String
            public let content: String
            
            public struct DominantMedia: Codable, Sendable {
                public let imageUrl: String
                public let authors: [Author]
            }
            
            public struct Author: Codable, Sendable {
                public let name: String
            }
        }
    }
    
    public subscript<T>(dynamicMember dynamicMember: KeyPath<ArticleDataWrapper.ArticleContents, T>) -> T {
        data.labsArticle[keyPath: dynamicMember]
    }
    
    public var id: String {
        self.slug
    }
}
