//
//  GetLabsArticle.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.News {
    struct GetLabsArticle: PennMobileEndpoint {
        public typealias Response = NewsArticle
        public let backend: EndpointBackend = .custom(baseURL: "https://labs-graphql-295919.ue.r.appspot.com")
        public let path = "/graphql"
        public let queryParams: [String: String]? = [
            "query": "{labsArticle{slug,headline,abstract,published_at,authors{name},dominantMedia{imageUrl,authors{name}},tag,content}}"
        ]

        public init() {}
    }
}
