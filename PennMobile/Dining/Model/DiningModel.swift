//
//  DiningModel.swift
//  PennMobile
//
//  Created by Josh Doman on 4/23/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

struct DiningHall {
    let name: String
    var timeRemaining: Int
    
    init(name: String, timeRemaining: Int) {
        self.name = name
        self.timeRemaining = timeRemaining
    }
    
    var times: [OpenClose]?
}

struct OpenClose: Equatable {
    let open: Date
    let close: Date
    
    static func ==(lhs: OpenClose, rhs: OpenClose) -> Bool {
        return lhs.open == rhs.open && lhs.close == rhs.close
    }
}
