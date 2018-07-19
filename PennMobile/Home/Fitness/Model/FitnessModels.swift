//
//  FitnessModels.swift
//  PennMobile
//
//  Created by dominic on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct FitnessSchedules: Codable {
    let schedules: [FitnessSchedule]
    
    enum CodingKeys : String, CodingKey {
        case schedules = "schedule"
    }
}

struct FitnessSchedule: Codable {
    let allDay: Bool
    let name: FitnessFacilityName
    let start: Date
    let end: Date
    
    enum CodingKeys : String, CodingKey {
        case allDay = "all_day"
        case name = "name"
        case start = "start"
        case end = "end"
    }
}
