//
//  GSRGroupUser.swift
//  PennMobile
//
//  Created by Daniel Salib on 11/8/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct GSRGroupUser: Codable{
    let pennkey: String!
    let groups: [GSRGroup]?
    
    enum CodingKeys: String, CodingKey {
        case pennkey = "username"
        case groups = "booking_groups"
    }
}

struct GSRInviteSearchResult: Codable, Equatable {
    let username: String
    let bookingGroups: [GSRGroup]

    enum CodingKeys: String, CodingKey {
        case username
        case bookingGroups = "booking_groups"
    }
    
    static func == (lhs: GSRInviteSearchResult, rhs: GSRInviteSearchResult) -> Bool {
        return lhs.username == rhs.username
    }
}

typealias GSRInviteSearchResults = [GSRInviteSearchResult]
