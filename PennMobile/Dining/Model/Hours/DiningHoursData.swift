//
//  DiningHours.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

/*
import Foundation

class DiningHoursDataDeprecated {
    
    static let shared = DiningHoursDataDeprecated()
    
    fileprivate var document: DiningAPIResponse.Document = .init(venues: [])
    
    lazy var todayString = {
        return Date.dayOfMonthFormatter.string(from: Date())
    }()
    
    ////////////
    
    
    
    
    
    ////////
    
    
    fileprivate var hasBeenLoaded = false
    fileprivate var hoursDictionary = Dictionary<String, [OpenClose]>()
    
    private let accessQueue = DispatchQueue(label: "SynchronizedHoursDictionaryAccess", attributes: .concurrent)
    
    func load(hours: [OpenClose], for venue: DiningVenueName) {
        load(hours: hours, on: todayString, for: venue)
    }
    
    func load(hours: [OpenClose], on day: String, for venue: DiningVenueName) {
        self.accessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.hasBeenLoaded = true
            self.hoursDictionary["\(venue.getID()).\(day)"] = hours
        }
    }
    
    func getHours(for venue: DiningVenueName) -> [OpenClose]? {
        return getHours(for: venue, on: todayString)
    }
    
    func getHours(for venue: DiningVenueName, on day: String) -> [OpenClose]? {
        var hours: [OpenClose]? = nil
        
        self.accessQueue.sync {
            hours = self.hoursDictionary["\(venue.getID()).\(day)"]
            if self.hasBeenLoaded {
                hours = hours ?? []
            }
        }
        return hours
    }
    
    func clearHours() {
        self.accessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.hoursDictionary = Dictionary<String, [OpenClose]>()
            self.hasBeenLoaded = false
        }
    }
}
*/
