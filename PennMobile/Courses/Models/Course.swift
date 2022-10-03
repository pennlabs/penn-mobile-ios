//
//  Course.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

private func getTimeInt(pathAtPennString: String) -> Int? {
    guard let time = Int(pathAtPennString) else {
        return nil
    }

    let hour = time / 100
    guard (0..<24).contains(hour) else {
        return nil
    }

    let minute = time % 100
    guard (0..<60).contains(minute) else {
        return nil
    }

    return hour * 60 + minute
}

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
    /// Initializes a course from Path@Penn data.
    init(_ data: PathAtPennNetworkManager.CourseData) {
        crn = data.crn
        code = data.code
        title = data.title
        section = data.section

        let instructorHTML = try? SwiftSoup.parse(data.instructordetail_html)
        let divs = try? instructorHTML?.select("div")
        instructors = (try? divs?.map { try $0.text(trimAndNormaliseWhitespace: true) }) ?? []

        let meetingHTML = try? SwiftSoup.parse(data.meeting_html)
        let a = try? meetingHTML?.select("a").first()
        location = try? a?.text(trimAndNormaliseWhitespace: true)

        struct PathAtPennMeetingTime: Decodable {
            var meet_day: String
            var start_time: String
            var end_time: String
        }

        if let sectionData = data.allInGroup.first(where: { $0.crn == data.crn }) {
            startDate = sectionData.start_date
            endDate = sectionData.end_date

            do {
                let timeData = try sectionData.meetingTimes.data(using: .utf8).unwrap(orThrow: PathAtPennError.corruptString)
                let rawTimes = try JSONDecoder().decode([PathAtPennMeetingTime].self, from: timeData)
                meetingTimes = rawTimes.compactMap { time in
                    // Path@Penn returns 0 through 6 for Monday to Sunday
                    // We need to map that to 1 through 7 for Sunday to Saturday
                    guard let dayInt = Int(time.meet_day), (0...6).contains(dayInt) else {
                        print("Got invalid weekday: \(time.meet_day)")
                        return nil
                    }
                    let weekday = (dayInt + 2) % 7

                    guard let start = getTimeInt(pathAtPennString: time.start_time),
                          let end = getTimeInt(pathAtPennString: time.end_time) else {
                        return nil
                    }

                    return MeetingTime(weekday: weekday, startTime: start, endTime: end)
                }
            } catch let error {
                meetingTimes = []
                print("Couldn't parse meeting times: \(error)")
            }
        } else {
            startDate = nil
            endDate = nil
            meetingTimes = nil
        }
    }
}
