//
//  CourseSection.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct CourseSection: Decodable, Sendable {
    public let section: String
    public let status: String
    public let activity: String
    public let meetingTimes: String
    public let instructors: [Instructor]
    public let courseTitle: String

    enum CodingKeys: String, CodingKey {
        case status, activity, instructors
        case section = "section_id"
        case meetingTimes = "meeting_times"
        case courseTitle = "course_title"
    }
}
