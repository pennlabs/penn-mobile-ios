//
//  Machine.swift
//  PennMobile
//
//  Created by Josh Doman on 12/2/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

class Machine: Hashable {
    
    enum Status: String {
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
    
    let id: Int
    let isWasher: Bool
    let roomName: String
    var status: Status
    var timeRemaining: Int
        
    init(json: JSON, roomName: String) {
        self.roomName = roomName
        id = json["id"].intValue
        let statusStr = json["status"].stringValue
        status = Status(rawValue: statusStr) ?? Status.parseStatus(for: statusStr)
        timeRemaining = json["time_remaining"].intValue
        isWasher = json["type"].stringValue == "washer"
        
        // Flag if website does not provide a time remaining
        if status == .running && timeRemaining == 0 {
            timeRemaining = -1
        }
    }
    
    var hashValue: Int {
        return "\(roomName)\(isWasher)\(id)".hashValue
    }
    
    func isUnderNotification() -> Bool {
        return LaundryNotificationCenter.shared.isUnderNotification(for: self)
    }
}

// MARK: - Comparable
extension Machine: Comparable {
    static func <(lhs: Machine, rhs: Machine) -> Bool {
        switch (lhs.status, rhs.status) {
        case (.running, .open):
            return true
        case (.open, .running):
            return false
        case (_, .offline),
             (_, .outOfOrder):
            return true
        case (.offline, _),
             (.outOfOrder, _):
            return false
        default:
            return lhs.timeRemaining < rhs.timeRemaining
        }
    }
    
    static func ==(lhs: Machine, rhs: Machine) -> Bool {
        return lhs.roomName == rhs.roomName
            && lhs.id == rhs.id
            && lhs.isWasher == rhs.isWasher
    }
}

// MARK: - Array Extensions
extension Array where Element == Machine {
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
