//
//  Course.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

/// A time that a course meets.
struct MeetingTime: Codable {
    /// Weekday of the meeting time.
    ///
    /// 1 corresponds to Sunday, 7 corresponds to Saturday.
    var weekday: Int

    /// Time that the meeting time starts, in minutes after midnight.
    var startTime: Int

    /// Time that the meeting time ends, in minutes after midnight.
    var endTime: Int
}

struct Course: Codable {
    /// Time zone to use in course calculations.
    static let timezone = TimeZone(identifier: "EST")
    
    /// Calendar to use in course calculations.
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let timezone {
            calendar.timeZone = timezone
        }
        return calendar
    }()
    
    /// Identifier of this course on Path@Penn.
    var crn: String

    /// The course's short code (for example, CIS 1200.)
    var code: String

    /// The course's long title.
    var title: String

    /// The course's section number.
    var section: String

    /// The course's instructors.
    var instructors: [String]

    /// The course's location.
    ///
    /// Generally in the format "BUILDING ROOM".
    var location: String?

    /// The start date of the course.
    var startDate: Date?

    /// The end date of the course.
    var endDate: Date?

    /// An array of meeting times for the course.
    var meetingTimes: [MeetingTime]?
}

// Literally here so SwiftUI is happy
extension Course: Identifiable {
    var id: String { crn }
}

extension Course {
    init(dummyCourseWithCode code: String,
         title: String,
         section: String,
         location: String?,
         startHour: Int,
         startMinute: Int,
         endHour: Int,
         endMinute: Int) {
        let meetingTimes = (1...7).map {
            MeetingTime(weekday: $0, startTime: startHour * 60 + startMinute, endTime: endHour * 60 + endMinute)
        }
        
        self.init(crn: UUID().uuidString,
                  code: code,
                  title: title,
                  section: section,
                  instructors: [],
                  location: location,
                  startDate: Date.distantPast,
                  endDate: Date.distantFuture,
                  meetingTimes: meetingTimes)
    }
}
