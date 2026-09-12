//
//  DiningStationItem.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 26/6/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct DiningStationItem: Codable, Hashable {
    public let id: Int
    public let name: String
    public let desc: String
    public let ingredients: String

    public enum CodingKeys: String, CodingKey {
        case id = "item_id"
        case name
        case desc = "description"
        case ingredients
    }
}
