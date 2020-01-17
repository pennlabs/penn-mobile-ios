//
//  Model.swift
//  PennMobile
//
//  Created by Josh Doman on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct HousingResult: Codable {
    let house: String?
    let room: String?
    let address: String?
    let start: Int
    let end: Int
    let offCampus: Bool
}
