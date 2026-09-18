//
//  VenueInfo.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 26/6/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct VenueInfo: Codable, Hashable {
    public let id: Int
    public let name: String
    public let image: String
    
    public enum CodingKeys: String, CodingKey {
        case id = "venue_id"
        case name
        case image = "image_url"
    }
}
