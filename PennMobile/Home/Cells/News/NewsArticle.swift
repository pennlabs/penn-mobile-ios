//
//  NewsArticle.swift
//  PennMobile
//
//  Created by Josh Doman on 2/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct NewsArticle: Codable {
    let source: String
    let link: String
    let title: String
    let subtitle: String
    let timestamp: String
    let imageurl: String
}
