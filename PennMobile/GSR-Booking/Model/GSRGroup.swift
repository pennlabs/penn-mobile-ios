//
//  GSRGroup.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct GSRGroup {
    let id: String
    let name: String
    let color: String
    let createdAt: Date
    let userSettings: GSRGroupIndividualSettings
    
    var imgURL: String?
    var owners: [GSRGroupMember]?
    var members: [GSRGroupMember]?
    let reservations: [String]? //array of reservationID's
    let groupSettings: GSRGroupAccessSettings?
}

struct GSRGroupIndividualSettings { //specific to a user within a group
    var pennKeyActive: Bool
    var notificationsOn: Bool
}
struct GSRGroupAccessSettings { //general to all users within a group
    var booking: GSRGroupAccessPermissions
    var invitation: GSRGroupAccessPermissions
}

enum GSRGroupAccessPermissions { //who has access
    case everyone
    case owner
}

struct GSRGroupMember {
    let accountID: String
    let pennKey: String
    let first: String
    let last: String
    let email: String?
    let isBookingEnabled: Bool
    let isAdmin: Bool
}
