//
//  Post.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct Post: Codable {
    let id: Int
    let title: String?
    let subtitle: String?
    let postUrl: String?
    let imageUrl: String
    let createdDate: Date
    let startDate: Date
    let expireDate: Date
    let source: String?
}
