//
//  Structs.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

public struct GSRLocation {
    var name : String
    var code : Int
    var path : String
}

public struct GSRDate {
    var string : String
    var compact : String
    var day : Int
}

open class GSRHour : NSObject {
    var id : Int = 0
    var start : String = ""
    var end : String = ""
    var prev : GSRHour?
    var next : GSRHour?
    
    public init(id: Int, start: String, end: String, prev: GSRHour?) {
        self.id = id
        self.start = start
        self.end = end
        self.prev = prev
    }
    
    open override var description: String {
        return start + " - " + end
    }
}

extension Array where Element: GSRHour {
    public mutating func setAppend(_ newElement: Element) {
        if (!self.contains(newElement)) {
            self.append(newElement)
        }
    }
}

extension Dictionary where Key == String, Value == [GSRHour] {
    var sortedKeys: [Key] {
        get {
            return keys.sorted(by: { (key1, key2) -> Bool in
                guard let arr1 = self[key1] else { return false }
                guard let arr2 = self[key2] else { return true }
                if arr1.isEmpty || arr2.isEmpty { return false }
                let start1 = arr1.first!
                let start2 = arr2.first!
                let start1Time = Parser.getDateFromTime(time: start1.start)
                let start2Time = Parser.getDateFromTime(time: start2.start)
                if start1Time == start2Time {
                    if let next1 = start1.next {
                        guard let next2 = start2.next else { return true }
                        if next1.next != nil {
                            if next2.next != nil {
                                return arr1.count > arr2.count
                            } else {
                                return true
                            }
                        } else if next2.next != nil { return false }
                        return arr1.count > arr2.count
                    }
                    if start2.next != nil { return false }
                    return arr1.count > arr2.count
                } else {
                    return start1Time < start2Time
                }
            })
        }
    }
    
    var firstOpening: Date {
        get {
            if self.isEmpty { return Parser.midnight }
            var tempEarliestTime = Parser.midnight.tomorrow
            self.forEach { (_, value) in
                if let firstHour = value.first {
                    let firstTime = Parser.getDateFromTime(time: firstHour.start)
                    tempEarliestTime = Swift.min(firstTime, tempEarliestTime)
                }
            }
            return tempEarliestTime
        }
    }
    
    var lastOpening: Date {
        get {
            if self.isEmpty { return Parser.midnight.tomorrow }
            var tempLastEndtime = Parser.midnight
            for key in keys {
                guard let gsrArr = self[key], let lastHour = gsrArr.last else { continue }
                let lastEndTime = Parser.getDateFromTime(time: lastHour.end)
                if lastEndTime > tempLastEndtime { tempLastEndtime = lastEndTime }
            }
            return tempLastEndtime
        }
    }
    
    func parse(from start: Date, to end: Date) -> Dictionary<String, [GSRHour]> {
        var timeSlots = Dictionary<String, [GSRHour]>()
        for (key, value) in self {
            let arr = value.filter({ (hour) -> Bool in
                let startHour = Parser.getDateFromTime(time: hour.start).localTime
                return start <= startHour && startHour < end
            })
            timeSlots[key] = arr.isEmpty ? nil : arr
        }
        return timeSlots
    }
}
