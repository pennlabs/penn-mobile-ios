//
//  LaundryHall.swift
//  Penn Mobile
//
//  Created by Zhilei Zheng on 2017/10/24.
//  Copyright © 2017年 Zhilei Zheng. All rights reserved.
//
import Foundation
import SwiftyJSON
import PennMobileShared

class LaundryRoom: Codable {

    static let directory = "laundryHallData-v2.json"

    enum CodingKeys: String, CodingKey {
        case id = "hall_id"
        case name
        case building = "location"
    }

    let id: Int
    let name: String
    let building: String

    var washers = [LaundryMachine]()
    var dryers = [LaundryMachine]()

    var usageData: [Double]! = nil

    init(id: Int, name: String, building: String) {
        self.id = id
        self.name = name
        self.building = building
    }

    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["hall_name"].string ?? "Unknown"
        self.building = json["location"].string ?? "Unknown"

        let runningMachines = json["machines"]["details"].arrayValue.map { LaundryMachine(json: $0, roomName: name) }
        washers = runningMachines.filter { $0.isWasher }.sorted()
        dryers = runningMachines.filter { !$0.isWasher }.sorted()

        let usageJSON = json["usage_data"]
        guard let washerData = usageJSON["washer_data"].dictionary, let dryerData = usageJSON["dryer_data"].dictionary else { return }

        usageData = [Double](repeating: 0, count: 27)
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
        UserDefaults.standard.setLaundryPreferences(to: ids)
    }

    static func setPreferences(for halls: [LaundryRoom]) {
        let ids = halls.map { $0.id }
        LaundryRoom.setPreferences(for: ids)
    }

    static func getPreferences() -> [LaundryRoom] {
        if UIApplication.isRunningFastlaneTest {
            var halls = [LaundryRoom]()
            for id in [1, 2, 3] {
                if let hall = getLaundryHall(for: id) {
                    halls.append(hall)
                }
            }
            return halls
        } else {
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
    static func == (lhs: LaundryRoom, rhs: LaundryRoom) -> Bool {
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

// MARK: - Default Room
extension LaundryRoom {
    static func getDefaultRoom() -> LaundryRoom {
        return LaundryRoom(id: 0, name: "Bishop White", building: "Quad")
    }
}
