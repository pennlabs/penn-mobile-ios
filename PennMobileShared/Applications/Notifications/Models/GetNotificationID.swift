//
//  GetNotificationID.swift
//  PennMobile
//
//  Created by Kunli Zhang on 30/10/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

public struct GetNotificationID: Codable, Identifiable, Sendable {
    public let id: Int
    public let kind: String
    public let token: String
}
