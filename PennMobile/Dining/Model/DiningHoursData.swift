//
//  DiningHours.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class DiningHoursData {
    
    static let shared = DiningHoursData()
    
    fileprivate var hoursDictionary = Dictionary<DiningVenueName, [OpenClose]>()
    
    func load(hours: [OpenClose], for venue: DiningVenueName) {
        hoursDictionary[venue] = hours
    }
    
    func getHours(for venue: DiningVenueName) -> [OpenClose]? {
        return hoursDictionary[venue]
    }
    
    func clearHours() {
        hoursDictionary = Dictionary<DiningVenueName, [OpenClose]>()
    }
}
