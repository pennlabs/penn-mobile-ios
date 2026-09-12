//
//  ScannedTicket.swift
//  PennMobile
//
//  Created by Anthony Li on 4/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public struct ScannedTicket: Sendable {
    public enum InvalidReason: Error {
        case malformedTicket
        case badRequest(String)
        case notFound
    }
    
    public enum Status: Sendable {
        case valid(Ticket)
        case duplicate(Ticket)
        case invalid(InvalidReason)
    }
    
    public var status: Status
    public var scanTime: Date
    
    public init(status: Status, scanTime: Date) {
        self.status = status
        self.scanTime = scanTime
    }
}
