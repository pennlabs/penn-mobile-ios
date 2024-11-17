//
//  NotificationAPIModel.swift
//  PennMobile
//
//  Created by Kunli Zhang on 30/10/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

struct GetNotificationID: Codable, Identifiable {
    let id: Int
    let kind: String
    let token: String
}
