//
//  GSRReservation.swift
//  PennMobile
//
//  Created by Josh Doman on 2/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct GSRReservation: Codable, Equatable, Identifiable {
    var id: String {
        return bookingId
    }
    let bookingId: String
    let gsr: GSRLocation
    let roomId: Int
    let roomName: String
    let start: Date
    let end: Date
    
    // Present only for /share responses
    let ownerName: String?
}
