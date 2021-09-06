//
//  GSRReservation.swift
//  PennMobile
//
//  Created by Josh Doman on 2/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

enum GSRService: String {
    case wharton
    case libcal
}

struct GSRReservation: Codable {
    let bookingId: String
    let gsr: GSRLocation
    let roomId: Int
    let roomName: String
    let start: Date
    let end: Date
}
