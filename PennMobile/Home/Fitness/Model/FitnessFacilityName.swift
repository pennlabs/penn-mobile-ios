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
    case ringe =       "Penn Squash Center"
    case climbing =    "Climbing Wall"
    case membership =  "Membership"
    case fox =         "Fox Fitness"
    case pottruck =    "Pottruck"
    case rockwell =    "Pottruck Court"
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
    
    func getImageName() -> String? {
        switch self {
        case .sheerr: return "sheerr"
        case .ringe: return "ringe"
        case .climbing: return "climbing"
        case .membership: return "membership"
        case .fox: return "fox"
        case .pottruck: return "pottruck"
        case .rockwell: return "rockwell"
        default: return nil
        }
    }
}
