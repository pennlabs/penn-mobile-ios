//
//  DiningAPIResponse.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// Top level structure of Dining API response
struct DiningAPIResponse: Codable {
    let document: DiningDocument
}

struct DiningDocument: Codable {
    let venues: [DiningVenue]
    enum CodingKeys: String, CodingKey {
        case venues = "venue"
    }
}
