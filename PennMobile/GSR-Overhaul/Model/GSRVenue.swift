//
//  GSRVenue.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public class GSRVenue {
    var name: String
    var id: Int
    var rooms: [GSRRoom]?
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
}
