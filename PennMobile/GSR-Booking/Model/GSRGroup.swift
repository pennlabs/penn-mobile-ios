//
//  GSRGroup.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct GSRGroup: Decodable, Comparable {
    let id: Int
    let name: String
    let color: UIColor
    let owner: String?
    let members: [GSRGroupMember]?
    var userSettings: GSRGroupIndividualSettings?
    
    //not used right now
    var reservations: [String]? //array of reservationID's
    var groupSettings: GSRGroupAccessSettings?
    
    static let groupColors: [String : UIColor] = [
        "Labs Blue" : UIColor.baseLabsBlue,
        "College Green" : UIColor.baseGreen,
        "Locust Yellow" : UIColor.baseYellow,
        "Cheeto Orange": UIColor.baseOrange,
        "Gritty Orange": UIColor.baseOrange,
        "Red-ing Terminal": UIColor.baseRed,
        "Baltimore Blue": UIColor.baseDarkBlue,
        "Pottruck Purple": UIColor.basePurple
    ]
    
    static func parseColor(color: String) -> UIColor? {
        return GSRGroup.groupColors[color]
    }
    enum CodingKeys: String, CodingKey {
        case id, name, color, owner
        case members = "memberships"
        case pennkeyAllow = "pennkey_allow"
        case notifications
    }
    
    fileprivate mutating func parseIndividualSettings(for pennkey: String) {
        //initializes the user settings based on the member data
        //call this method after initially decoding json data, and BEFORE
        // displaying groups in ManageGroupVC
        guard let members = members else { return }
        for member in members {
            if (member.pennKey == pennkey) {
                let pennKeyActive = member.pennKeyActive
                let notificationsOn = member.notificationsOn
                let pennKeyActiveSetting = GSRGroupIndividualSetting(type: .pennkeyActive, isEnabled: pennKeyActive)
                let notificationsOnSetting = GSRGroupIndividualSetting(type: .notificationsOn, isEnabled: notificationsOn)
                userSettings = GSRGroupIndividualSettings(pennKeyActive: pennKeyActiveSetting, notificationsOn: notificationsOnSetting)
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let id: Int = try keyedContainer.decode(Int.self, forKey: .id)
        let name: String = try keyedContainer.decode(String.self, forKey: .name)
        let colorString: String = try keyedContainer.decode(String.self, forKey: .color)
        let owner: String? = try keyedContainer.decodeIfPresent(String.self, forKey: .owner)
        
        self.id = id
        self.name = name
        self.color = GSRGroup.parseColor(color: colorString) ?? UIColor.baseBlue
        self.owner = owner
        
        if let members: [GSRGroupMember] = try keyedContainer.decodeIfPresent([GSRGroupMember].self, forKey: .members) {
            self.members = members
            guard let pennkey = Account.getAccount()?.username else { //this feels wrong :(
                print("user not signed in")
                return
            }
            parseIndividualSettings(for: pennkey)
        } else {
            self.members = nil
            let pennKeyActive = try keyedContainer.decode(Bool.self, forKey: .pennkeyAllow)
            let notifications = try keyedContainer.decode(Bool.self, forKey: .notifications)
            self.userSettings = GSRGroupIndividualSettings(pennKeyActive: GSRGroupIndividualSetting(type: .pennkeyActive, isEnabled: pennKeyActive), notificationsOn: GSRGroupIndividualSetting(type: .notificationsOn, isEnabled: notifications))
        }
    }
    
    static func < (lhs: GSRGroup, rhs: GSRGroup) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
    
    static func == (lhs: GSRGroup, rhs: GSRGroup) -> Bool {
        return lhs.id == rhs.id
    }
}

typealias GSRGroups = [GSRGroup]

enum GSRGroupIndividualSettingType: Int, Codable {
    case pennkeyActive
    case notificationsOn
}

struct GSRGroupIndividualSetting: Codable {
    var title: String {
        switch type {
        case .pennkeyActive:
            return "PennKey Permission"
        case .notificationsOn:
            return "Notifications"
        }
    }
    var type: GSRGroupIndividualSettingType
    var descr: String {
        switch type {
        case .notificationsOn:
            return "You’ll receive a notification any time a room is booked by this group."
        case .pennkeyActive:
            return "Anyone in this group can book a study room block using your PennKey."
        }
    }
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
    let pennKeyActive: Bool
    let notificationsOn: Bool
    let isAdmin: Bool
    
    enum CodingKeys: String, CodingKey {
        case pennKey = "user"
        case first, last //this doesn't get used
        case pennKeyActive = "pennkey_allow"
        case notificationsOn = "notifications"
        case isAdmin = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let memberType = try keyedContainer.decode(String.self, forKey: .isAdmin)
        let pennKeyActive = try keyedContainer.decode(Bool.self, forKey: .pennKeyActive)
        let notificationsOn = try keyedContainer.decode(Bool.self, forKey: .notificationsOn)
        
        self.isAdmin = (memberType == "A")
        self.pennKeyActive = pennKeyActive
        self.notificationsOn = notificationsOn
        
        let user = try keyedContainer.decode(GSRGroupMemberUser.self, forKey: .pennKey)
        self.pennKey = user.pennKey
        self.first = user.first
        self.last = user.last
    }
}

struct GSRGroupMemberUser: Codable {
    let pennKey: String
    let first: String
    let last: String
    
    enum CodingKeys: String, CodingKey {
        case pennKey = "username"
        case first = "first_name"
        case last = "last_name"
    }
}

struct GSRGroupInvite: Codable {
    let user: GSRInviteUser
    let group: String
    let type: String
    let pennkeyAllow: Bool
    let notifications: Bool
    let id: Int
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case user, type, group
        case pennkeyAllow = "pennkey_allow"
        case notifications, id
        case color
    }
}

struct GSRInviteUser: Codable {
    let pennkey: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case pennkey = "username"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

typealias GSRGroupInvites = [GSRGroupInvite]
