//
//  GSRTimeSlot.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public class GSRTimeSlot: NSObject {
    let roomId: Int
    let isAvailable: Bool
    let startTime: Date
    let endTime: Date
    
    weak var prev: GSRTimeSlot? = nil
    weak var next: GSRTimeSlot? = nil
    
    init(roomId: Int, isAvailable: Bool, startTime: Date, endTime: Date) {
        self.roomId = roomId
        self.isAvailable = isAvailable
        self.startTime = startTime
        self.endTime = endTime
    }
    
    static func ==(lhs: GSRTimeSlot, rhs: GSRTimeSlot) -> Bool {
        return lhs.roomId == rhs.roomId && lhs.isAvailable == rhs.isAvailable && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
    
    func getLocalTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, h:mm a"
        let dateStringStart = formatter.string(from: self.startTime)
        let dateStringEnd = formatter.string(from: self.endTime)
        return "\(dateStringStart) -> \(dateStringEnd)"
    }

}

extension Array where Element: GSRTimeSlot {
    var numberInRow: Int {
        if count == 0 { return 0 }
        var num = 1
        var currTime: GSRTimeSlot = first!
        while currTime.next != nil {
            num += 1
            currTime = currTime.next!
        }
        return num
    }
    
    var first60: GSRTimeSlot? {
        for slot in self {
            if slot.next != nil {
                return slot
            }
        }
    }
    
    var first90: GSRTimeSlot? {
        for slot in self {
            if slot.next != nil && slot.next!.next != nil {
                return slot
            }
        }
    }
}
