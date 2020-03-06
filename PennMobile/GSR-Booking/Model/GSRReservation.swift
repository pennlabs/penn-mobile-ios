//
//  GSRReservation.swift
//  PennMobile
//
//  Created by Josh Doman on 2/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

enum GSRService: String, Codable {
    case wharton
    case libcal
}

struct GSRReservation: Codable {
    let roomName: String
    let gid: Int
    let lid: Int
    let bookingID: String
    let startDate: Date
    let endDate: Date
    let service: GSRService
}
