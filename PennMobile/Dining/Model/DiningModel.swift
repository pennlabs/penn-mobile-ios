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
}
