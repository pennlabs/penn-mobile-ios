//
//  LaundryHall.swift
//  Penn Mobile
//
//  Created by Zhilei Zheng on 2017/10/24.
//  Copyright © 2017年 Zhilei Zheng. All rights reserved.
//
import Foundation
import SwiftyJSON

class LaundryRoom: Codable {
    
    static let directory = "laundryHallData.json"
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case building
    }
    
    let id: Int
    let name: String
    let building: String
    
    var washers = [LaundryMachine]()
    var dryers = [LaundryMachine]()
    
    var usageData: Array<Double>! = nil
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["hall_name"].string ?? "Unknown"
        self.building = json["location"].string ?? "Unknown"
        
        let runningMachines = json["machines"]["details"].arrayValue.map { LaundryMachine(json: $0, roomName: name) }
        washers = runningMachines.filter { $0.isWasher }.sorted()
        dryers = runningMachines.filter { !$0.isWasher }.sorted()
        
        let usageJSON = json["usage_data"]
        guard let washerData = usageJSON["washer_data"].dictionary, let dryerData = usageJSON["dryer_data"].dictionary else { return }
        
        usageData = Array<Double>(repeating: 0, count: 27)
        washerData.forEach { (key, val) in
            usageData[Int(key)!] = val.doubleValue
        }
        dryerData.forEach { (key, val) in
            usageData[Int(key)!] += val.doubleValue
        }
        
        let dataMax = usageData.max()!
        let dataMin = usageData.min()!
        if dataMin == dataMax {
            usageData = Array.init(repeating: 0.01, count: usageData.count)
        } else {
            for i in usageData.indices {
                usageData[i] = ((dataMax - usageData[i]) / (dataMax - dataMin))
            }
        }
    }
    
    static func getLaundryHall(for id: Int) -> LaundryRoom? {
        return LaundryAPIService.instance.idToRooms?[id]
    }
    
    static func setPreferences(for ids: [Int]) {
        UserDefaults.standard.set(preferences: ids)
    }
    
    static func setPreferences(for halls: [LaundryRoom]) {
        let ids = halls.map { $0.id }
        UserDefaults.standard.set(preferences: ids)
    }
    
    static func getPreferences() -> [LaundryRoom] {
        if let ids = UserDefaults.standard.getLaundryPreferences() {
            var halls = [LaundryRoom]()
            for id in ids {
                if let hall = getLaundryHall(for: id) {
                    halls.append(hall)
                }
            }
            return halls
        }
        return [LaundryRoom]()
    }
    
    func decrementTimeRemaining(by minutes: Int) {
        washers.decrementTimeRemaining(by: minutes)
        dryers.decrementTimeRemaining(by: minutes)
        washers = washers.sorted()
        dryers = dryers.sorted()
    }
}

// MARK: - Equatable
extension LaundryRoom: Equatable {
    static func ==(lhs: LaundryRoom, rhs: LaundryRoom) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Array Extension
extension Array where Element == LaundryRoom {
    func containsRunningMachine() -> Bool {
        return filter({ (hall) -> Bool in
            return hall.washers.containsRunningMachine() || hall.dryers.containsRunningMachine()
        }).count > 0
    }
}

// MARK: - Default Selection
extension LaundryRoom {
    static func getDefaultRooms() -> [LaundryRoom] {
        var rooms = getPreferences()
        while rooms.count < 3 {
            let lastId = rooms.last?.id ?? -1
            guard let nextRoom = getLaundryHall(for: lastId + 1) else { continue }
            rooms.append(nextRoom)
        }
        return rooms
    }
}
