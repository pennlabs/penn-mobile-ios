//
//  NotificationSetting.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

public struct NotificationSetting: Codable, Identifiable, Sendable {
    public let id: Int
    public let service: NotificationPreference
    public var enabled: Bool
}
