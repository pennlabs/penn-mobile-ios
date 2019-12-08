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
    let color: String?
    let createdAt: Date?
    let userSettings: GSRGroupIndividualSettings? //not optional, beacuse we need to know if pennKey is Active

    var imgURL: String?
    var owners: [GSRGroupMember]?
    var members: [GSRGroupMember]?
    let reservations: [String]? //array of reservationID's
    let groupSettings: GSRGroupAccessSettings?
    
    static let groupColors: [String : UIColor] = [
        "Labs Blue" : UIColor(red: 32, green: 156, blue: 238),
        "College Green" : UIColor(red: 63, green: 170, blue: 109),
        "Locust Yellow" : UIColor(red: 255, green: 207, blue: 89),
        "Cheeto Orange": UIColor(red: 250, green: 164, blue: 50),
        "Red-ing Terminal": UIColor(red: 226, green: 81, blue: 82),
        "Baltimore Blue": UIColor(red: 51, green: 101, blue: 143),
        "Purple": UIColor(red: 131, green: 79, blue: 160)
    ]
    
    func parseColor() -> UIColor? {
        guard let color = self.color else { return nil }
        
        return GSRGroup.groupColors[color]
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
    let accountID: String
    let pennKey: String
    let first: String
    let last: String
    let email: String?
    let isBookingEnabled: Bool
    let isAdmin: Bool
}
