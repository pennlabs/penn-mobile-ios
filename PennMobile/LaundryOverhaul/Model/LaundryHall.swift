//
//  LaundryHall.swift
//  Penn Mobile
//
//  Created by Zhilei Zheng on 2017/10/24.
//  Copyright © 2017年 Zhilei Zheng. All rights reserved.
//
import Foundation
import SwiftyJSON

class LaundryHall: Codable {
    
    static let directory = "laundryHallData.json"
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case building
    }
    
    // fields, get() by laundryHall.fieldName, set() only available through network calls
    let id: Int
    let name: String
    let building: String
    
    public private(set) var numWasherOpen = 0
    public private(set) var numWasherRunning = 0
    public private(set) var numWasherOutOfOrder = 0
    public private(set) var numWasherOffline = 0
    public private(set) var remainingTimeWashers = [Int]()
    public private(set) var numDryerOpen = 0
    public private(set) var numDryerRunning = 0
    public private(set) var numDryerOutOfOrder = 0
    public private(set) var numDryerOffline = Int()
    public private(set) var remainingTimeDryers = [Int]()
    
    // Keeps track of the washers/dryers that are under notification
    // Ex: if the firstWasher is under notification, then dryersUnderNotification.contains(0) is true
    fileprivate var dryersUnderNotification = [Int]()
    fileprivate var washersUnderNotification = [Int]()
        
    // instantiation
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["hall_name"].string ?? "Unknown"
        self.building = json["location"].string ?? "Unknown"
    }
    
    init(json: JSON, id:Int) {
        self.id = id
        self.name = json["hall_name"].string ?? "Unknown"
        self.building = json["location"].string ?? "Unknown"
        let washers:JSON = json["machines"]["washers"]
        let dryers:JSON = json["machines"]["dryers"]
        self.numWasherOpen = washers["open"].intValue
        self.numWasherRunning = washers["running"].intValue
        self.numWasherOutOfOrder = washers["out_of_order"].intValue
        self.numWasherOffline = washers["offline"].intValue
        self.numDryerOpen = dryers["open"].intValue
        self.numDryerRunning = dryers["running"].intValue
        self.numDryerOutOfOrder = dryers["out_of_order"].intValue
        self.numDryerOffline = dryers["offline"].intValue
        
        if let arr = washers["time_remaining"].arrayObject {
            for time in arr {
                if let t = time as? Int, t >= 0 {
                    remainingTimeWashers.append(t)
                }
            }
            remainingTimeWashers.sort()
        }
        
        if let arr = dryers["time_remaining"].arrayObject {
            for time in arr {
                if let t = time as? Int, t >= 0 {
                    remainingTimeDryers.append(t)
                }
            }
            remainingTimeDryers.sort()
        }
        
        //updateUnderNotification()
    }
    
    static func getLaundryHall(for id: Int) -> LaundryHall? {
        return LaundryAPIService.instance.idToHalls?[id]
    }
    
    static func setPreferences(for ids: [Int]) {
        UserDefaults.standard.set(preferences: ids)
    }
    
    static func setPreferences(for halls: [LaundryHall]) {
        let ids = halls.map { $0.id }
        UserDefaults.standard.set(preferences: ids)
    }
    
    static func getPreferences() -> [LaundryHall] {
        if let ids = UserDefaults.standard.getLaundryPreferences() {
            var halls = [LaundryHall]()
            for id in ids {
                if let hall = getLaundryHall(for: id) {
                    halls.append(hall)
                }
            }
            return halls
        }
        return [LaundryHall]()
    }
    
    func decrementMinutesRemaining() {
        var newDryersTimes = [Int]()
        for time in remainingTimeDryers {
            if time > 1 {
                newDryersTimes.append(time - 1)
            }
        }
        
        var newWashersTimes = [Int]()
        for time in remainingTimeWashers {
            if time > 1 {
                newWashersTimes.append(time - 1)
            }
        }
        
        numDryerOpen += remainingTimeDryers.count - newDryersTimes.count
        numDryerRunning = newDryersTimes.count
        
        numWasherOpen += remainingTimeWashers.count - newWashersTimes.count
        numWasherRunning = newWashersTimes.count
        
        remainingTimeDryers = newDryersTimes
        remainingTimeWashers = newWashersTimes
        
        //updateUnderNotification()
    }
}

extension LaundryHall: Equatable {
    static func ==(lhs: LaundryHall, rhs: LaundryHall) -> Bool {
        return lhs.id == rhs.id
    }
}

// Historic Usage Data Fetching
extension LaundryHall {
    // fetch usage data
    func getUsageData(for type: MachineType) -> [Float] {
        return UsageData.shared.getData(for: self, type: type)
    }
}

// Under notification functions
extension LaundryHall {    
    func isUnderNotification(isWasher: Bool, timeRemaining: Int) -> Bool {
        return isWasher ? washersUnderNotification.contains(timeRemaining) : dryersUnderNotification.contains(timeRemaining)
    }
    
    func updateUnderNotification(completion: @escaping () -> Void) {
        LaundryNotificationCenter.shared.getTimeRemainingForOutstandingNotifications(for: self, isWasher: true, timeRemainingArray: remainingTimeWashers) { (timesUnderNotification) in
            self.washersUnderNotification = timesUnderNotification
            
            
            LaundryNotificationCenter.shared.getTimeRemainingForOutstandingNotifications(for: self, isWasher: false, timeRemainingArray: self.remainingTimeDryers) { (timesUnderNotification) in
                self.dryersUnderNotification = timesUnderNotification
                completion()
            }
        }
    }
    
    func updateUnderNotification() {
        LaundryNotificationCenter.shared.getTimeRemainingForOutstandingNotifications(for: self, isWasher: true, timeRemainingArray: remainingTimeWashers) { (timesUnderNotification) in
            self.washersUnderNotification = timesUnderNotification
        }
        
        LaundryNotificationCenter.shared.getTimeRemainingForOutstandingNotifications(for: self, isWasher: false, timeRemainingArray: self.remainingTimeDryers) { (timesUnderNotification) in
            self.dryersUnderNotification = timesUnderNotification
        }
    }
}
