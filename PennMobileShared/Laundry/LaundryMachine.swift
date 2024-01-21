//
//  Machine.swift
//  PennMobile
//
//  Created by Josh Doman on 12/2/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

public class LaundryMachine: Hashable, Codable {

    public enum Status: String, Codable {
        case open
        case running
        case offline
        case outOfOrder = "out_of_order"

        static func parseStatus(for status: String) -> Status {
            if status == "Not online" {
                return .offline
            } else if status == "Almost done" || status == "In use" {
                return .running
            } else if status == "Out of order" {
                return .outOfOrder
            } else {
                return .open
            }
        }
    }

    public let id: Int
    public let isWasher: Bool
    public let roomName: String
    public var status: Status
    public var timeRemaining: Int
    
    public init(id: Int, isWasher: Bool, roomName: String, status: Status, timeRemaining: Int) {
        self.id = id
        self.isWasher = isWasher
        self.roomName = roomName
        self.status = status
        self.timeRemaining = timeRemaining
    }

    public convenience init(json: JSON, roomName: String) {
        let statusStr = json["status"].stringValue
        let status = Status(rawValue: statusStr) ?? Status.parseStatus(for: statusStr)
        var timeRemaining = json["time_remaining"].intValue
        
        // Flag if website does not provide a time remaining
        if status == .running && timeRemaining == 0 {
            timeRemaining = -1
        }
        
        self.init(id: json["id"].intValue, isWasher: json["type"].stringValue == "washer", roomName: roomName, status: status, timeRemaining: timeRemaining)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(roomName)
        hasher.combine(isWasher)
        hasher.combine(id)
    }
}

// MARK: - Comparable
extension LaundryMachine: Comparable {
    public static func < (lhs: LaundryMachine, rhs: LaundryMachine) -> Bool {
//        switch (lhs.status, rhs.status) {
//        case (.running, .open):
//            return true
//        case (.open, .running):
//            return false
//        case (_, .offline),
//             (_, .outOfOrder):
//            return true
//        case (.offline, _),
//             (.outOfOrder, _):
//            return false
//        default:
//            return lhs.timeRemaining < rhs.timeRemaining
//        }
        return lhs.id < rhs.id
    }

    public static func == (lhs: LaundryMachine, rhs: LaundryMachine) -> Bool {
        return lhs.roomName == rhs.roomName
            && lhs.id == rhs.id
            && lhs.isWasher == rhs.isWasher
    }
}

// MARK: - Array Extensions
public extension Array where Element == LaundryMachine {
    func containsRunningMachine() -> Bool {
        if self.count == 0 { return false }
        return self[0].status == .running
    }

    func numberOpenMachines() -> Int {
        return filter { $0.status == .open }.count
    }

    func decrementTimeRemaining(by minutes: Int) {
        forEach {
            if $0.status == .running {
                $0.timeRemaining -= minutes

                if $0.timeRemaining == 0 {
                    $0.status = .open
                }
            }
        }
    }
}
