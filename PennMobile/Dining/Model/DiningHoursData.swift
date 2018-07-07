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
    
    fileprivate var hoursDictionary = Dictionary<String, [OpenClose]>()
    
    lazy var todayString = {
        return OpenClose.dateFormatter.string(from: Date())
    }()
    
    func load(hours: [OpenClose], for venue: DiningVenueName) {
        hoursDictionary["\(venue.getID()).\(todayString)"] = hours
    }
    
    func load(hours: [OpenClose], on day: String, for venue: DiningVenueName) {
        hoursDictionary["\(venue.getID()).\(day)"] = hours
    }
    
    func getHours(for venue: DiningVenueName) -> [OpenClose]? {
        return hoursDictionary["\(venue.getID()).\(todayString)"]
    }
    
    func getHours(for venue: DiningVenueName, on day: String) -> [OpenClose]? {
        return hoursDictionary["\(venue.getID()).\(day)"]
    }
    
    func clearHours() {
        hoursDictionary = Dictionary<String, [OpenClose]>()
    }
}
