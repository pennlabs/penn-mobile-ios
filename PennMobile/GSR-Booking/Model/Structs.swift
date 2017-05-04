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
                if arr1.isEmpty { return false }
                if arr2.isEmpty { return false }
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
}


// MARK: - Turning raw data to structs

public func generateHour(hour rawHour : AnyObject, prev: GSRHour?) -> GSRHour {
    
    if let id = rawHour.object(forKey: "id") as? Int {
        
        let start = rawHour.object(forKey: "start_time") as! String
        let end = rawHour.object(forKey: "end_time") as! String
        
        return GSRHour(id: id, start: start, end: end, prev: prev)
    }
    
    return GSRHour(id: 0, start: "", end: "",prev: nil)
    
}

public func generateRoomData(_ rawRoomData : AnyObject) -> Dictionary<String, [GSRHour]> {
    
    var roomData = Dictionary<String, [GSRHour]>()
    
    let roomDict = rawRoomData as! NSDictionary
    
    for (room, hoursArray) in roomDict {
        let title = room as! String
        let rawHours = hoursArray as! NSArray
        var hours = [GSRHour]()
        for (index, rawHour) in rawHours.enumerated() {
            if (index == 0) {
                let hour = generateHour(hour: rawHour as AnyObject, prev: nil)
                hours.append(hour)
            } else {
                let hour = generateHour(hour: rawHour as AnyObject, prev: nil)
                let prev = hours[index - 1]
                
                if (hour.start == prev.end) {
                    hour.prev = prev
                    prev.next = hour
                }
                
                hours.append(hour)
            }
        }
        
        roomData[title] = hours
    }
    
    return roomData
}
