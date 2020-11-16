//
//  FitnessModels.swift
//  PennMobile
//
//  Created by dominic on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct FitnessSchedules: Codable {
    let schedules: [FitnessSchedule?]?
    
    enum CodingKeys : String, CodingKey {
        case schedules = "schedule"
    }
}

struct FitnessSchedule: Codable {
    let name: FitnessFacilityName
    let hours: [FitnessScheduleOpenClose]
    
    enum CodingKeys : String, CodingKey {
        case name = "name"
        case hours = "hours"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.hours = try container.decode([FitnessScheduleOpenClose].self, forKey: .hours)
        do {
            self.name = try container.decodeIfPresent(FitnessFacilityName.self, forKey: .name) ?? .unknown
        } catch {
            self.name = .unknown
            if let unknownName = try? container.decodeIfPresent(String.self, forKey: .name) {
                print("ERROR: Unknown fitness facility name - \(unknownName ?? "")")
            }
        }
    }
}

struct FitnessScheduleOpenClose: Codable {
    
    let allDay: Bool
    let start: Date?
    let end: Date?
    
    enum CodingKeys : String, CodingKey {
        case allDay = "all_day"
        case start = "start"
        case end = "end"
    }
}
