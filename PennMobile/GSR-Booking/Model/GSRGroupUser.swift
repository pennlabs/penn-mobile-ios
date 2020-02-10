//
//  GSRGroupUser.swift
//  PennMobile
//
//  Created by Daniel Salib on 11/8/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct GSRInviteSearchResult: Codable, Equatable, Comparable {
    
    let first: String?
    let last: String?
    let email: String?
    let pennkey: String
    
    static func == (lhs: GSRInviteSearchResult, rhs: GSRInviteSearchResult) -> Bool {
        return lhs.pennkey == rhs.pennkey
    }
    
    static func == (lhs: GSRInviteSearchResult, rhs: GSRGroupMember) -> Bool {
        return lhs.pennkey == rhs.pennKey
    }
    
    static func < (lhs: GSRInviteSearchResult, rhs: GSRInviteSearchResult) -> Bool {
        return lhs.pennkey < rhs.pennkey
    }
}

typealias GSRInviteSearchResults = [GSRInviteSearchResult]
