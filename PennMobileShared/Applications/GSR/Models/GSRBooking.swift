//
//  GSRBooking.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct GSRBooking: Codable, Sendable {
    public let gid: Int
    public let startTime: Date
    public let endTime: Date
    public let id: Int
    public let roomName: String
    
    public init(gid: Int, startTime: Date, endTime: Date, id: Int, roomName: String) {
        self.gid = gid
        self.startTime = startTime
        self.endTime = endTime
        self.id = id
        self.roomName = roomName
    }

    public func getLocalTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, h:mm a"
        let dateStringStart = formatter.string(from: self.startTime)
        let dateStringEnd = formatter.string(from: self.endTime)
        return "\(dateStringStart) -> \(dateStringEnd)"
    }
}
