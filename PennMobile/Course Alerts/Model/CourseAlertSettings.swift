//
//  CourseAlertSettings.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/31/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct CourseAlertSettings: Decodable {
    let username, first_name, last_name: String
    let profile: CourseAlertProfile
}

struct CourseAlertProfile: Decodable {
    let email, phone: String
    let push_notifications: Bool
}

