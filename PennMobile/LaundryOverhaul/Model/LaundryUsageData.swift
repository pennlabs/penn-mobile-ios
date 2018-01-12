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
    
    static var dataForRoom = Dictionary<Int, LaundryUsageData>()
    
    let id: Int
    let name: String
    let numberOfMachines: Int
    let usageData: Array<Float>
    
    init(id: Int, json: JSON) throws {
        self.id = id
        guard let name = json["hall_name"].string else {
            throw "Bad format"
        }
        self.name = name
        self.numberOfMachines = Int(json["total_number_of_washers"].floatValue)
        var data = Array<Float>(repeating: 0, count: 27)
        json["washer_data"].dictionaryValue.forEach { (key, val) in
            data[Int(key)!] = val.floatValue
        }
        
        json["dryer_data"].dictionaryValue.forEach { (key, val) in
            data[Int(key)!] += val.floatValue
        }
        
        self.usageData = data.map { $0/2 }
    }
    
}
