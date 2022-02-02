//
//  CourseAlertSettings.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/31/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct CourseAlertSettings: Decodable {
    let username, firstName, lastName: String
    let profile: CourseAlertProfile
    
    enum CodingKeys: String, CodingKey {
        case username, profile
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
}

struct CourseAlertProfile: Decodable {
    let email, phone: String
    let pushNotifications: Bool
    
    enum CodingKeys: String, CodingKey {
        case email, phone
        case pushNotifications = "push_notifications"
    }
    
}
