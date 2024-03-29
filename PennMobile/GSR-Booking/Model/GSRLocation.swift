//
//  StudySpace.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct GSRLocation: Codable, Equatable {
    let lid: String
    let gid: Int
    let name: String
    let kind: GSRServiceType
    let imageUrl: String

    enum GSRServiceType: String, Codable {
        case wharton = "WHARTON"
        case libcal = "LIBCAL"
    }
}
