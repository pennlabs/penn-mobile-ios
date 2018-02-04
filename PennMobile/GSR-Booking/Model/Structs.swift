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
    
    var numberInRow: Int {
        if count == 0 { return 0 }
        return 1 + (first?.next == nil ? 0 : Array(dropFirst()).numberInRow)
    }
}

extension Dictionary where Key == String, Value == [GSRHour] {
    var sortedKeys: [Key] {
        get {
            return keys.sorted(by: { (key1, key2) -> Bool in
                guard let arr1 = self[key1] else { return false }
                guard let arr2 = self[key2] else { return true }
                guard let start1 = arr1.first?.start, let start2 = arr2.first?.start else { return false }
                let start1Time = Parser.getDateFromTime(time: start1)
                let start2Time = Parser.getDateFromTime(time: start2)
                if start1Time == start2Time {
                    let numRow1 = arr1.numberInRow
                    let numRow2 = arr2.numberInRow
                    if numRow1 == numRow2 {
                        return arr1.count > arr2.count
                    }
                    return numRow1 > numRow2
                }
                return start1Time < start2Time
            })
        }
    }
    
    var firstOpening: Date {
        get {
            if self.isEmpty { return Parser.midnightToday }
            var tempEarliestTime = Parser.midnightToday.tomorrow
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
            if self.isEmpty { return Parser.midnightToday.tomorrow }
            var tempEndTime = Parser.midnightToday
            for key in keys {
                guard let gsrArr = self[key], let lastHour = gsrArr.last else { continue }
                let lastEndTime = Parser.getDateFromTime(time: lastHour.end)
                tempEndTime = Swift.max(tempEndTime, lastEndTime)
            }
            return tempEndTime
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
