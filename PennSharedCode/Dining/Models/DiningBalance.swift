//
//  DiningBalance.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/20/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

public struct DiningBalance: Codable {
    public static let directory = "diningBalance.json"

    public let date: String
    public let diningDollars: String
    public let regularVisits: Int
    public let guestVisits: Int
    public let addOnVisits: Int
    
    public init(date: String, diningDollars: String, regularVisits: Int, guestVisits: Int, addOnVisits: Int) {
        self.date = date
        self.diningDollars = diningDollars
        self.regularVisits = regularVisits
        self.guestVisits = guestVisits
        self.addOnVisits = addOnVisits
    }
}
