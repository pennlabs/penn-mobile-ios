//
//  DiningVenue+UIExtensions.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// MARK: - VenueType
extension DiningVenue.VenueType {
    func getFullDisplayName() -> String {
        switch self {
        case .dining: return "Campus Dining Hall"
        case .retail: return "Campus Retail Dining"
        case .unknown: return "Other"
        }
    }
}
