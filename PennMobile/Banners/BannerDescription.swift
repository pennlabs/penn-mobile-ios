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
