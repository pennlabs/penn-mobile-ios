//
//  DiningBalances.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct DiningBalance: Codable {
    let diningDollars: Float
    let visits: Int
    let guestVisits: Int
    let lastUpdated: Date
}
