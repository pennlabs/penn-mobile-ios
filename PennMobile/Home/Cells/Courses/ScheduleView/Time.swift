//
//  Time.swift
//  Wen
//
//  Created by Josh Doman on 4/5/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

struct Time: Hashable {
    let hour: Int
    let minutes: Int
    let isAm: Bool

    func rawMinutes() -> Int {
        if isAm && hour == 12 {
            return minutes
        }
        var total = hour * 60 + minutes
        if !isAm && hour != 12 {
            total += 12*60
        }
        return total
    }

    var description: String {
        get {
            let am = isAm ? "AM" : "PM"
            return "\(hour):\(minutes) \(am)"
        }
    }
}
