//
//  DiningBalance.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/20/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

struct DiningBalance: Codable {
    let date: String
    let diningDollars: String
    let regularVisits: Int
    let guestVisits: Int
    let addOnVisits: Int
}
