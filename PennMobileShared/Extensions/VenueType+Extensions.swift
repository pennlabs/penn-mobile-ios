//
//  VenueType+Extensions.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

public extension VenueType {
    var fullDisplayName: String {
        switch self {
        case .dining: return "Dining Halls"
        case .retail: return "Retail Dining"
        }
    }
}
