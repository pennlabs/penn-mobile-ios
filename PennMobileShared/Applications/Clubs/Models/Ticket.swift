//
//  Ticket.swift
//  PennMobile
//
//  Created by Anthony Li on 4/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

public struct Ticket: Decodable, Sendable {
    public var id: String
    public var event: TicketEvent
    public var type: String
    public var owner: String
    
    // TODO: Make attended property non-optional when the backend returns it
    public var attended: Bool?
}
