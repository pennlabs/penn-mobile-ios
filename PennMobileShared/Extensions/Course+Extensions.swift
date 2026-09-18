//
//  Course+Extensions.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

extension Course: Identifiable {
    public var id: String { crn }
}

public extension Course {
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
