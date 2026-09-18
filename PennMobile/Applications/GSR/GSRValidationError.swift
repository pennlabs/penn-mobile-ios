//
//  GSRValidationError.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

enum GSRValidationError: LocalizedError {
    case overLimit(limit: Int)
    case differentRooms
    case splitTimeSlots
    case bookingInPast
    case notInWharton
    
    var errorDescription: String? {
        switch self {
        case .overLimit(let limit):
            "You cannot create a booking for more than \(limit) minutes at this location."
        case .differentRooms:
            "You cannot book two separate rooms at the same time."
        case .splitTimeSlots:
            "You must create a single, concurrent reservation."
        case .bookingInPast:
            "This timeslot is already elapsed."
        case .notInWharton:
            "You must be a Wharton student to view this location."
        }
    }
}
