//
//  CourseAlert.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct CourseAlert: Decodable, Sendable {
    public let id: Int
    public let createdAt: String
    public let originalCreatedAt: String
    public let updatedAt: String
    public let section: String
    public let user: String
    public let deleted: Bool
    public let autoResubscribe: Bool
    public let notificationSent: Bool
    public let notificationSentAt: String?
    public let closeNotification: Bool
    public let closeNotificationSent: Bool
    public let closeNotificationSentAt: String?
    public let deletedAt: String?
    public let isActive: Bool
    public let isWaitingForClose: Bool
    public let sectionStatus: String

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
