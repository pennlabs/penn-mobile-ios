//
//  Course.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

struct MeetingTime: Codable {
    var weekday: Int
    var startTime: DateComponents
    var endTime: DateComponents
}

struct Course: Codable {
    var crn: String
    var code: String
    var title: String
    var section: String
    var instructors: [String]

    var location: String?

    var startDate: Date?
    var endDate: Date?

    var meetingTimes: [MeetingTime]?
}

extension Course: Identifiable {
    var id: String { crn }
}

private extension DateComponents {
    init(weekday: Int, pathAtPennString: String) throws {
        let time = try Int(pathAtPennString).unwrap(orThrow: Course.ConversionError.invalidTimeString)

        let hours = time / 100
        guard (0..<24).contains(hours) else {
            throw Course.ConversionError.invalidTimeString
        }

        let minutes = time % 100
        guard (0..<60).contains(minutes) else {
            throw Course.ConversionError.invalidTimeString
        }

        self.init(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(identifier: "America/New_York"),
            hour: hours,
            minute: minutes,
            weekday: weekday)
    }
}

extension Course {
    enum ConversionError: Error {
        case invalidWeekday
        case invalidTimeString
    }

    init(_ data: PathAtPennNetworkManager.CourseData) {
        crn = data.crn
        code = data.code
        title = data.title
        section = data.section

        do {
            let instructorHTML = try SwiftSoup.parse(data.instructordetail_html)
            let divs = try instructorHTML.select("div")
            instructors = try divs.map { try $0.text(trimAndNormaliseWhitespace: true) }
        } catch let error {
            instructors = []
            print("Couldn't parse instructors: \(error)")
        }

        do {
            let meetingHTML = try SwiftSoup.parse(data.meeting_html)
            let a = try meetingHTML.select("a").first()
            location = try a?.text(trimAndNormaliseWhitespace: true)
        } catch let error {
            location = nil
            print("Couldn't parse meeting HTML: \(error)")
        }

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

                    do {
                        let start = try DateComponents(weekday: weekday, pathAtPennString: time.start_time)
                        let end = try DateComponents(weekday: weekday, pathAtPennString: time.end_time)
                        return MeetingTime(weekday: weekday, startTime: start, endTime: end)
                    } catch let error {
                        print("Couldn't parse start/end times: \(error)")
                        return nil
                    }
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
