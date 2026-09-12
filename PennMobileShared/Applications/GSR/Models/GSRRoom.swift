//
//  GSRRoom.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct GSRRoom: Codable, Hashable, Identifiable, Comparable, Sendable {
    // 1. Two rooms with a letter preceding numbers are sorted by that letter, then by the number
    // 2. Rooms with letters before a number appear before rooms with just a number
    // 3. Two rooms with just numbers are sorted by those numbers
    // 4. Rooms without numbers are sorted alphabetically
    public static func < (lhs: GSRRoom, rhs: GSRRoom) -> Bool {
        if let lhsLetter = lhs.precedingRoomLetter, let rhsLetter = rhs.precedingRoomLetter {
            if lhsLetter != rhsLetter {
                return lhsLetter < rhsLetter
            } else {
                if let lhsNum = lhs.roomNumber, let rhsNum = rhs.roomNumber {
                    return lhsNum < rhsNum
                } else {
                    return lhs.roomName < rhs.roomName
                }
            }
        }
        
        if lhs.precedingRoomLetter != nil {
            return true
        }
        
        if let lhsNum = lhs.roomNumber, let rhsNum = rhs.roomNumber {
            return lhsNum < rhsNum
        }
        
        return lhs.roomName < rhs.roomName
    }
    
    public let roomName: String
    public let id: Int
    public var availability: [GSRTimeSlot]
    
    public var roomNumber: Int? {
        let regex = /[0-9]+/
        if let match = roomNameShort.firstMatch(of: regex), let numInt = Int(match.0) {
            return numInt
        }
        return nil
    }
    
    public var precedingRoomLetter: String? {
        let regex = /([A-Z])([0-9]+)/
        if let match = roomNameShort.firstMatch(of: regex) {
            return String(match.1)
        }
        return nil
    }
    
    public var roomNameShort: String {
        self.roomName.split(separator: ":").first?.trimmingCharacters(in: .whitespaces) ?? roomName
    }
}
