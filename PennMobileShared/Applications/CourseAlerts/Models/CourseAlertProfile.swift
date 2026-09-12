//
//  CourseAlertProfile.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/31/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct CourseAlertProfile: Decodable, Sendable {
    public let email, phone: String
    public let pushNotifications: Bool

    enum CodingKeys: String, CodingKey {
        case email, phone
        case pushNotifications = "push_notifications"
    }
}
