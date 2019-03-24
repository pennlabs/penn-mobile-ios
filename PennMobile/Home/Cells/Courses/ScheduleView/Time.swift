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
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minutes == rhs.minutes && lhs.isAm == rhs.isAm
    }
    
    var hashValue: Int {
        get {
            var hash = hour.hashValue
            hash += (55*hash + minutes.hashValue)
            hash += (55*hash + isAm.hashValue)
            return hash
        }
    }
}
