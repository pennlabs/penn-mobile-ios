//
//  FitnessFacilityName.swift
//  PennMobile
//
//  Created by dominic on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

enum FitnessFacilityName: String, Codable {
    
    // These names reflect what is given by the API, do not change. Customize name in getFacilityName()
    case sheerr =      "Sheerr Pool"
    case ringe =       "Ringe"
    case climbing =    "Climbing Wall"
    case membership =  "Membership Services"
    case fox =         "Fox Fitness"
    case pottruck =    "Pottruck Hours"
    case rockwell =    "Basketball - Rockwell"
    case unknown
    
    static let all = [pottruck, fox, sheerr, climbing, ringe, rockwell, membership]
    
    func getFacilityName() -> String {
        switch self {
        case .pottruck: return "Pottruck Fitness"
        case .rockwell: return "Rockwell"
        case .ringe: return "Ringe"
        default: return self.rawValue
        }
    }
    
    static func getFacilityName(for apiName: String) -> FitnessFacilityName {
        for facility in FitnessFacilityName.all {
            if apiName.contains(facility.rawValue) {
                return facility
            }
        }
        return .unknown
    }
}
