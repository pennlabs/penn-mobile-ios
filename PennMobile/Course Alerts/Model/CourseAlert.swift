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
    
    init(id: Int, created_at: String, original_created_at: String, updated_at: String, section: String, user: String, deleted: Bool, auto_resubscribe: Bool, notification_sent: Bool, notification_sent_at: String?, close_notification: Bool, close_notification_sent: Bool, close_notification_sent_at: String?, deleted_at: String?, is_active: Bool, is_waiting_for_close: Bool, section_status: String) {
        self.id = id
        self.createdAt = created_at
        self.originalCreatedAt = original_created_at
        self.updatedAt = updated_at
        self.section = section
        self.user = user
        self.deleted = deleted
        self.autoResubscribe = auto_resubscribe
        self.notificationSent = notification_sent
        self.notificationSentAt = notification_sent_at
        self.closeNotification = close_notification
        self.closeNotificationSent = close_notification_sent
        self.closeNotificationSentAt = close_notification_sent_at
        self.deletedAt = deleted_at
        self.isActive = is_active
        self.isWaitingForClose = is_waiting_for_close
        self.sectionStatus = section_status
    }
    
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
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
                
        let id: Int = try keyedContainer.decode(Int.self, forKey: .id)
        let createdAt: String = try keyedContainer.decode(String.self, forKey: .createdAt)
        let originalCreatedAt: String = try keyedContainer.decode(String.self, forKey: .originalCreatedAt)
        let updatedAt: String = try keyedContainer.decode(String.self, forKey: .updatedAt)
        let section: String = try keyedContainer.decode(String.self, forKey: .section)
        let user: String = try keyedContainer.decode(String.self, forKey: .user)
        let deleted: Bool = try keyedContainer.decode(Bool.self, forKey: .deleted)
        let autoResubscribe: Bool = try keyedContainer.decode(Bool.self, forKey: .autoResubscribe)
        let notificationSent: Bool = try keyedContainer.decode(Bool.self, forKey: .notificationSent)
        let notificationSentAt: String? = try keyedContainer.decodeIfPresent(String.self, forKey: .notificationSentAt)
        let closeNotification: Bool = try keyedContainer.decode(Bool.self, forKey: .closeNotification)
        let closeNotificationSent: Bool = try keyedContainer.decode(Bool.self, forKey: .closeNotificationSent)
        let closeNotificationSentAt: String? = try keyedContainer.decodeIfPresent(String.self, forKey: .closeNotificationSentAt)
        let deletedAt: String? = try keyedContainer.decodeIfPresent(String.self, forKey: .deletedAt)
        let isActive: Bool = try keyedContainer.decode(Bool.self, forKey: .isActive)
        let isWaitingForClose: Bool = try keyedContainer.decode(Bool.self, forKey: .isWaitingForClose)
        let sectionStatus: String = try keyedContainer.decode(String.self, forKey: .sectionStatus)
        
        self.id = id
        self.createdAt = createdAt
        self.originalCreatedAt = originalCreatedAt
        self.updatedAt = updatedAt
        self.section = section
        self.user = user
        self.deleted = deleted
        self.autoResubscribe = autoResubscribe
        self.notificationSent = notificationSent
        self.notificationSentAt = notificationSentAt
        self.closeNotification = closeNotification
        self.closeNotificationSent = closeNotificationSent
        self.closeNotificationSentAt = closeNotificationSentAt
        self.deletedAt = deletedAt
        self.isActive = isActive
        self.isWaitingForClose = isWaitingForClose
        self.sectionStatus = sectionStatus
    }
    
}
