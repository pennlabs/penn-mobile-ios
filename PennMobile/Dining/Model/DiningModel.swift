//
//  DiningModel.swift
//  PennMobile
//
//  Created by Josh Doman on 4/23/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class DiningVenue: NSObject {
    var name: String
    var times: [OpenClose]?
    
    init(name: String) {
        self.name = name
    }
}

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
}
