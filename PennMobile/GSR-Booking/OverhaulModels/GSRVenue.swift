//
//  GSRVenue.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct GSRVenue {
    var name: String
    var id: Int
    var rooms: [Int:GSRRoom]
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
        self.rooms = [:]
    }
    
    mutating func addRoom(room: GSRRoom) {
        rooms[room.id] = room
    }
}
