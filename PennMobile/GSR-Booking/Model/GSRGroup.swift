//
//  GSRGroup.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct GSRGroup: Codable{
    let id: Int
    let name: String
    let color: String
    var userSettings: GSRGroupIndividualSettings? = nil//this prop is set AFTER via a parse
    let owner: String? //the pennkey
    let members: [GSRGroupMember]?
    
    //not used right now
    let reservations: [String]? //array of reservationID's
    let groupSettings: GSRGroupAccessSettings?
    let createdAt: Date?

    static let groupColors: [String : UIColor] = [
        "Labs Blue" : UIColor.baseBlue,
        "College Green" : UIColor.baseGreen,
        "Locust Yellow" : UIColor.baseYellow,
        "Cheeto Orange": UIColor.baseOrange,
        "Red-ing Terminal": UIColor.baseRed,
        "Baltimore Blue": UIColor.baseBlue,
        "Purple": UIColor.basePurple
    ]
    
    func parseColor() -> UIColor? {
        return GSRGroup.groupColors[color]
    }
    
    mutating func parseIndividualSettings(for pennkey: String) {
        //initializes the user settings based on the member data
        //call this method after initially decoding json data, and BEFORE
        // displaying groups in ManageGroupVC
        guard let members = members else { return }
        for member in members {
            if (member.pennKey == pennkey) {
                let pennKeyActive = member.pennKeyActive ?? false
                let notificationsOn = member.notificationsOn ?? false
                let pennKeyActiveSetting = GSRGroupIndividualSetting(title: "PennKey Permission", descr: "Anyone in this group can book a study room block using your PennKey.", isEnabled: pennKeyActive)
                let notificationsOnSetting = GSRGroupIndividualSetting(title: "Notifications", descr: "You’ll receive a notification any time a room is booked by this group.", isEnabled: notificationsOn)
                userSettings = GSRGroupIndividualSettings(pennKeyActive: pennKeyActiveSetting, notificationsOn: notificationsOnSetting)
            }
        }
    }
}

struct GSRGroupIndividualSetting: Codable {
    var title: String
    var descr: String
    var isEnabled: Bool
}

struct GSRGroupIndividualSettings: Codable { //specific to a user within a group
    var pennKeyActive: GSRGroupIndividualSetting
    var notificationsOn: GSRGroupIndividualSetting
}

struct GSRGroupAccessSettings: Codable { //general to all users within a group
    var booking: GSRGroupAccessPermissions
    var invitation: GSRGroupAccessPermissions
}

enum GSRGroupAccessPermissions: String, Codable { //who has access
    case everyone
    case owner
}

struct GSRGroupMember: Codable {
    let pennKey: String
    let first: String
    let last: String
    
    //TODO: make the following unoptional later (optional now for testing ONLY)
    let pennKeyActive: Bool?
    let notificationsOn: Bool?
    let isAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case pennKey = "username"
        case first = "first_name"
        case last = "last_name"
        case pennKeyActive
        case notificationsOn
        case isAdmin
    }
}

struct GSRGroupInvite: Codable {
    let pennkey: String
    let group: String
    let type: String
    let pennkeyAllow: Bool
    let notifications: Bool
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case pennkey = "username"
        case pennkeyAllow = "pennkey_allow"
        case notifications
        case id
        case type
        case group
    }
}

typealias GSRGroupInvites = [GSRGroupInvite]
