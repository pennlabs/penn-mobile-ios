//
//  CourseAlert.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct CourseAlert: Decodable {
    
    let id: Int
    let createdAt: String
    let originalCreatedAt: String
    let updatedAt: String
    let section: String
    let user: String
    let deleted: Bool
    let autoResubscribe: Bool
    let notificationSent: Bool
    let notificationSentAt: String?
    let closeNotification: Bool
    let closeNotificationSent: Bool
    let closeNotificationSentAt: String?
    let deletedAt: String?
    let isActive: Bool
    let isWaitingForClose: Bool
    let sectionStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id, section, user, deleted
        case createdAt = "created_at"
        case originalCreatedAt = "original_created_at"
        case updatedAt = "updated_at"
        case autoResubscribe = "auto_resubscribe"
        case notificationSent = "notification_sent"
        case notificationSentAt = "notification_sent_at"
        case closeNotification = "close_notification"
        case closeNotificationSent = "close_notification_sent"
        case closeNotificationSentAt = "close_notification_sent_at"
        case deletedAt = "deleted_at"
        case isActive = "is_active"
        case isWaitingForClose = "is_waiting_for_close"
        case sectionStatus = "section_status"
    }
    
}
