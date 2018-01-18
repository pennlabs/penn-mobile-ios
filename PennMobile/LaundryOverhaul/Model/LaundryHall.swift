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
    
    let id: Int
    let name: String
    let building: String
    
    public private(set) var washers = [Machine]()
    public private(set) var dryers = [Machine]()
    
    fileprivate var usageData: Array<Double>? = nil
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["hall_name"].string ?? "Unknown"
        self.building = json["location"].string ?? "Unknown"
    }
    
    init(json: JSON, id:Int) {
        self.id = id
        self.name = json["hall_name"].string ?? "Unknown"
        self.building = json["location"].string ?? "Unknown"
        
        let runningMachines = json["machines"]["details"].arrayValue
            .map { Machine(json: $0, roomName: name) }
        
        self.washers = runningMachines.filter { $0.isWasher }.sorted()
        self.dryers = runningMachines.filter { !$0.isWasher }.sorted()
        
        self.usageData = LaundryUsageData.dataForRoom[self.id]?.usageData
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
    
    func decrementTimeRemaining(by minutes: Int) {
        washers.decrementTimeRemaining(by: minutes)
        dryers.decrementTimeRemaining(by: minutes)
        
        washers.sort()
        dryers.sort()
    }
}

// MARK: - Equatable
extension LaundryHall: Equatable {
    static func ==(lhs: LaundryHall, rhs: LaundryHall) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - UsageData
extension LaundryHall {
    func getUsageData() -> Array<Double>? {
        return usageData
    }
}

// MARK: - Array Extension
extension Array where Element == LaundryHall {
    func containsRunningMachine() -> Bool {
        return filter({ (hall) -> Bool in
            return hall.washers.containsRunningMachine() || hall.dryers.containsRunningMachine()
        }).count > 0
    }
}
