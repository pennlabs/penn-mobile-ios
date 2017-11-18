//
//  UsageData.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2017/11/18.
//  Copyright © 2017年 PennLabs. All rights reserved.
//

import Foundation

class UsageData {
    static let shared = UsageData()
    
    private var washerData = [Int:[Float]]()
    private var dryerData = [Int:[Float]]()
    
    func getData(for hall: LaundryHall, type machineType: MachineType) -> [Float]{
        if machineType == MachineType.washer {
            if let dataForHall = washerData[hall.id] {
                return dataForHall
            } else {
                return []
            }
        } else {
            if let dataForHall = dryerData[hall.id] {
                return dataForHall
            } else {
                return []
            }
        }
    }
    
    
    
}

enum MachineType {
    case washer
    case dryer
}
