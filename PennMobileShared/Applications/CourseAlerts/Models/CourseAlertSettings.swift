//
//  CourseAlertSettings.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/31/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct CourseAlertSettings: Decodable, Sendable {
    public let username, firstName, lastName: String
    public let profile: CourseAlertProfile

    enum CodingKeys: String, CodingKey {
        case username, profile
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
