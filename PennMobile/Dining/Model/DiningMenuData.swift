//
//  DiningMenuData.swift
//  PennMobile
//
//  Created by Dominic on 7/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class DiningMenuData {
    
    static let shared = DiningMenuData()
    
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
