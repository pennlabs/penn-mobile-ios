//
//  LaundryUsageData.swift
//  PennMobile
//
//  Created by Josh Doman on 12/9/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

extension String: Error {}

class LaundryUsageData {
    
    fileprivate static var dataForRoom = Dictionary<Int, LaundryUsageData>()
    fileprivate static var currentDayForData = Date()
    
    let id: Int
    let name: String
    let numberOfMachines: Int
    let data: Array<Double>
    
    init(id: Int, json: JSON) throws {
        self.id = id
        guard let name = json["hall_name"].string else {
            throw "Bad format"
        }
        self.name = name
        self.numberOfMachines = Int(json["total_number_of_washers"].doubleValue)
        var data = Array<Double>(repeating: 0, count: 27)
        json["washer_data"].dictionaryValue.forEach { (key, val) in
            data[Int(key)!] = val.doubleValue
        }
        
        json["dryer_data"].dictionaryValue.forEach { (key, val) in
            data[Int(key)!] += val.doubleValue
        }
        
        // Edit the data to look good displayed on a graph
        let dataMax = data.max() ?? 1.0
        let dataMin = data.min() ?? 0.0
        for i in data.indices {
            // 1 - (totalMachinesOpen / numberOfMachinesInRoom) -> 0...1 where 0 is low traffic and 1 is high
            data[i] = ((dataMax - data[i]) / (dataMax - dataMin))
        }
        
        self.data = data.map { $0 }
    }
    
    static func set(usageData: LaundryUsageData, for id: Int) {
        dataForRoom[id] = usageData
    }
    
    static func getUsageData(for id: Int) -> LaundryUsageData? {
        return dataForRoom[id]
    }
    
    static func containsUsageData(for id: Int) -> Bool {
        return getUsageData(for: id) != nil
    }
    
    static func clearIfNewDay() {
        if !NSCalendar.current.isDateInToday(currentDayForData) {
            dataForRoom = Dictionary<Int, LaundryUsageData>()
            currentDayForData = Date()
        }
    }
}

// MARK: - Equatable
extension LaundryUsageData: Equatable {
    static func ==(lhs: LaundryUsageData, rhs: LaundryUsageData) -> Bool {
        return lhs.id == rhs.id && lhs.data == rhs.data
    } 
}

