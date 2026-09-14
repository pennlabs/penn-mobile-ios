//
//  DiningBalance.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 2/20/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

public struct DiningBalance: Codable, Sendable {
    public let date: String
    public let diningDollars: String
    public let regularVisits: Int
    public let guestVisits: Int
    public let addOnVisits: Int
    
    /// A zeroed-out balance, shown before a balance has been fetched.
    public static var empty: DiningBalance {
        DiningBalance(date: Date.dayOfMonthFormatter.string(from: Date()), diningDollars: "0.0", regularVisits: 0, guestVisits: 0, addOnVisits: 0)
    }

    public init(date: String, diningDollars: String, regularVisits: Int, guestVisits: Int, addOnVisits: Int) {
        self.date = date
        self.diningDollars = diningDollars
        self.regularVisits = regularVisits
        self.guestVisits = guestVisits
        self.addOnVisits = addOnVisits
    }
}
