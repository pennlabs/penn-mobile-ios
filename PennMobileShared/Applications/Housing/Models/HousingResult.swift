//
//  HousingResult.swift
//  PennMobile
//
//  Created by Josh Doman on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

public struct HousingResult: Codable, Sendable {
    public let house: String?
    public let room: String?
    public let address: String?
    public let start: Int
    public let end: Int
    public let offCampus: Bool
}
