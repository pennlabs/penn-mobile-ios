//
//  PennCoordinates.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class PennCoordinates {
    
    static let shared = PennCoordinates()
    static let collegeHall: (Double, Double) = (39.9522, -75.1932)
    
    func getCoordinates(for venue: DiningVenueName) -> (Double, Double) {
        switch venue {
        case .commons: return (1.0, 1.0)
        default: return PennCoordinates.collegeHall
        }
    }
    
    func getCoordinates(for facility: FitnessFacilityName) -> (Double, Double) {
        switch facility {
        case .pottruck: return (0.0, 0.0)
        default: return PennCoordinates.collegeHall
        }
    }
}

//Two functions : get from DiningVenue, get from FitnessFacilityName.

