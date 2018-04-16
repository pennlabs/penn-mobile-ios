//
//  OpenClose.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct OpenClose: Equatable {
    let open: Date
    let close: Date
    
    static func ==(lhs: OpenClose, rhs: OpenClose) -> Bool {
        return lhs.open == rhs.open && lhs.close == rhs.close
    }
    
    var description: String {
        return open.description + " - " + close.description
    }
    
    func overlaps(with oc: OpenClose) -> Bool {
        return (oc.open >= self.open && oc.open < self.close) || (self.open >= oc.open && self.open < oc.close)
    }
    
    func withoutMinutes() -> OpenClose {
        let newOpen = open.roundedDownToHour
        let newClose = close.roundedDownToHour
        return OpenClose(open: newOpen, close: newClose)
    }
}

// MARK: - Array Extension
extension Array where Element == OpenClose {
    func containsOverlappingTime(with oc: OpenClose) -> Bool {
        for e in self {
            if e.overlaps(with: oc) { return true }
        }
        return false
    }
    
    mutating func removeAllMinutes() {
        self = self.map({ (oc) -> OpenClose in
            oc.withoutMinutes()
        })
    }
    
    var isOpen: Bool {
        let now = Date()
        for open_close in self {
            if open_close.open < now && open_close.close > now {
                return true
            }
        }
        return false
    }
    
    var strFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        
        var firstOpenClose = true
        var timesString = ""
        
        for open_close in self {
            if open_close.open.minutes == 0 {
                formatter.dateFormat = self.count > 1 ? "h" : "ha"
            } else {
                formatter.dateFormat = self.count > 1 ? "h:mm" : "h:mma"
            }
            let open = formatter.string(from: open_close.open)
            
            if open_close.close.minutes == 0 {
                formatter.dateFormat = self.count > 1 ? "h" : "ha"
            } else {
                formatter.dateFormat = self.count > 1 ? "h:mm" : "h:mma"
            }
            let close = formatter.string(from: open_close.close)
            
            if firstOpenClose {
                firstOpenClose = false
            } else {
                timesString += "  |  "
            }
            timesString += "\(open) - \(close)"
        }
        
        if self.isEmpty {
            timesString = ""
        }
        return timesString
    }
}
