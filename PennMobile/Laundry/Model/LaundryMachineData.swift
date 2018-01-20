//
//  LaundryMachineData.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class LaundryMachineData {
    
    let roomId: Int
    var washers: [LaundryMachine]
    var dryers: [LaundryMachine]
    
    init(roomId: Int, washers: [LaundryMachine], dryers: [LaundryMachine]) {
        self.roomId = roomId
        self.washers = washers
        self.dryers = dryers
    }
    
    init(json: JSON, id: Int) {
        self.roomId = id
        let name = json["hall_name"].string ?? "Unknown"
        let runningMachines = json["machines"]["details"].arrayValue.map { LaundryMachine(json: $0, roomName: name) }
        
        washers = runningMachines.filter { $0.isWasher }.sorted()
        dryers = runningMachines.filter { !$0.isWasher }.sorted()
    }
    
    fileprivate static var machineDictionary = Dictionary<Int, LaundryMachineData>()
    
    static func set(washers: [LaundryMachine], dryers: [LaundryMachine], for id: Int) {
        machineDictionary[id] = LaundryMachineData(roomId: id, washers: washers, dryers: dryers)
    }
    
    static func set(laundryMachineData: LaundryMachineData) {
        machineDictionary[laundryMachineData.roomId] = laundryMachineData
    }
    
    static func getMachines(for id: Int) -> LaundryMachineData {
        return machineDictionary[id] ?? LaundryMachineData(roomId: id, washers: [], dryers: [])
    }
}
