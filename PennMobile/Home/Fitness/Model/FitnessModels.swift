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
    let allDay: Bool
    let name: FitnessFacilityName
    let start: Date?
    let end: Date?
    
    enum CodingKeys : String, CodingKey {
        case allDay = "all_day"
        case name = "name"
        case start = "start"
        case end = "end"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.allDay = try container.decode(Bool.self, forKey: .allDay)
        self.start = try container.decodeIfPresent(Date.self, forKey: .start)
        self.end = try container.decodeIfPresent(Date.self, forKey: .end)
        do {
            self.name = try container.decodeIfPresent(FitnessFacilityName.self, forKey: .name) ?? .unknown
        } catch {
            self.name = .unknown
        }
    }
}

/*
struct MenuItem: Codable {
    let attributes: MenuItemAttributes?
    let title: String
    let description: String
    
    enum CodingKeys : String, CodingKey {
        case attributes = "tblAttributes"
        case title = "txtTitle"
        case description = "txtDescription"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        do {
            self.attributes = try container.decodeIfPresent(MenuItemAttributes.self, forKey: .attributes)
        } catch {
            self.attributes = nil
        }
    }
}*/
