//
//  GSRReservation.swift
//  PennMobile
//
//  Created by Josh Doman on 2/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

public struct GSRReservation: Codable, Equatable, Identifiable, Sendable {
    public var id: String {
        return bookingId
    }
    public let bookingId: String
    public let gsr: GSRLocation
    public let roomId: Int
    public let roomName: String
    public let start: Date
    public let end: Date
    
    // Present only for /share responses
    public let ownerName: String?
    public let isValid: Bool?
}
