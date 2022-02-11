//
//  CourseSection.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//
import Foundation

struct CourseSection: Decodable {

    let section: String
    let status: String
    let activity: String
    let meetingTimes: String
    let instructors: [Instructor]
    let courseTitle: String

    enum CodingKeys: String, CodingKey {
        case status, activity, instructors
        case section = "section_id"
        case meetingTimes = "meeting_times"
        case courseTitle = "course_title"
    }

}

struct Instructor: Decodable {
    let id: Int
    let name: String
}
