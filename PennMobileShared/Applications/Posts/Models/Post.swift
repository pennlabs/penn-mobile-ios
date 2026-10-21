//
//  Post.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

public struct Post: Codable, Identifiable, Sendable {
    public let id: Int
    public let title: String?
    public let subtitle: String?
    public let postUrl: String?
    public let imageUrl: String
    public let createdDate: Date
    public let startDate: Date
    public let expireDate: Date
    public let source: String?

    public init(id: Int, title: String?, subtitle: String?, postUrl: String?, imageUrl: String, createdDate: Date, startDate: Date, expireDate: Date, source: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.postUrl = postUrl
        self.imageUrl = imageUrl
        self.createdDate = createdDate
        self.startDate = startDate
        self.expireDate = expireDate
        self.source = source
    }
}
