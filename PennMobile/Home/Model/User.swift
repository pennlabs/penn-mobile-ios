//
//  User.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class User: NSObject {
    let preferredVenues: [DiningVenue]
    let preferredLaundryRooms: [LaundryRoom]
    
    init(preferredVenues: [DiningVenue], preferredLaundryRooms: [LaundryRoom]) {
        self.preferredVenues = preferredVenues
        self.preferredLaundryRooms = preferredLaundryRooms
        super.init()
    }
    
    // MARK: - Default Behavior
    convenience override init() {
        self.init(preferredVenues: [], preferredLaundryRooms: LaundryRoom.getDefaultRooms())
    }
}
