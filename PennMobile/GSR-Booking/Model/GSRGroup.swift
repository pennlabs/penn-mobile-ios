//
//  GSRGroup.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct GSRGroup {
    let groupID: String
    let groupName: String
    let createdAt: Date
    let isActive: Bool
    let members: [GSRGroupMember]
}

struct GSRGroupMember {
    let accountID: String
    let first: String
    let last: String
    let email: String?
    let enabled: Bool
}
