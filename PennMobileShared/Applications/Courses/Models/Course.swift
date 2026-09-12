//
//  Course.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

public struct Course: Codable, Sendable {
    /// Time zone to use in course calculations.
    public static let timezone = TimeZone(identifier: "America/New_York")

    /// Calendar to use in course calculations.
    public static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let timezone {
            calendar.timeZone = timezone
        }
        return calendar
    }()

    public static let cacheFileName = "coursesCache"

    /// Identifier of this course on Path@Penn.
    public var crn: String

    /// The course's short code (for example, CIS 1200.)
    public var code: String

    /// The course's long title.
    public var title: String

    /// The course's section number.
    public var section: String

    /// The course's instructors.
    public var instructors: [String]

    /// The course's location.
    ///
    /// Generally in the format "BUILDING ROOM".
    public var location: String?

    /// The start date of the course.
    public var startDate: Date?

    /// The end date of the course.
    public var endDate: Date?

    /// An array of meeting times for the course.
    public var meetingTimes: [MeetingTime]?
    
    public init(crn: String,
                code: String,
                title: String,
                section: String,
                instructors: [String],
                location: String? = nil,
                startDate: Date?,
                endDate: Date?,
                meetingTimes: [MeetingTime]? = nil) {
        
        self.crn = UUID().uuidString
        self.code = code
        self.title = title
        self.section = section
        self.instructors = instructors
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.meetingTimes = meetingTimes
    }
}
