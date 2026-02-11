//
//  StudySpace.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct GSRLocation: Codable, Equatable, Hashable {
    let id: Int? // for gsr share
    
    let lid: String
    let gid: Int
    let name: String
    let kind: GSRServiceType
    let imageUrl: String

    enum GSRServiceType: String, Codable, Hashable {
        case wharton = "WHARTON"
        case libcal = "LIBCAL"
        
        var maxConsecutiveBookings: Int {
            switch self {
            case .wharton:
                return 3
            case .libcal:
                return 4
            }
        }
    }
}
