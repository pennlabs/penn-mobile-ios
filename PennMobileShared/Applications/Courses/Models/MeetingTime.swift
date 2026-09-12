//
//  MeetingTime.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

/// A time that a course meets.
public struct MeetingTime: Codable, Sendable {
    /// Weekday of the meeting time.
    ///
    /// 1 corresponds to Sunday, 7 corresponds to Saturday.
    public var weekday: Int

    /// Time that the meeting time starts, in minutes after midnight.
    public var startTime: Int

    /// Time that the meeting time ends, in minutes after midnight.
    public var endTime: Int
    
    public init(weekday: Int, startTime: Int, endTime: Int) {
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
    }
}
