//
//  BannerDescription.swift
//  PennMobile
//
//  Created by Anthony Li on 3/24/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

struct BannerDescription: Equatable, Codable {
    var image: URL
    var text: String
    var action: URL?
}

struct UserEngagementMessageDescription: Codable {
    var primary: String?
    var secondary: String?
    var actions: [Action]

    struct Action: Codable {
        var url: URL
        var title: String
    }
}
