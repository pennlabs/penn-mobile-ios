//
//  DiningMenu.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 26/6/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

public struct DiningMenu: Codable, Hashable {
    public let venueInfo: VenueInfo
    public let date: Date
    public let startTime: String
    public let endTime: String
    public let stations: [DiningStation]
    public let service: String

    public enum CodingKeys: String, CodingKey {
        case venueInfo = "venue"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case stations
        case service
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.venueInfo = try container.decode(VenueInfo.self, forKey: .venueInfo)
        self.date = try container.decode(Date.self, forKey: .date)
        self.startTime = try container.decode(String.self, forKey: .startTime)
        self.endTime = try container.decode(String.self, forKey: .endTime)
        self.service = try container.decode(String.self, forKey: .service)
        
        self.stations = try container.decode([DiningStation].self, forKey: .stations).sorted {
            if (DiningStation.getWeight(station: $0) == DiningStation.getWeight(station: $1)) {
                return $0.name > $1.name
            }
            return DiningStation.getWeight(station: $0) < DiningStation.getWeight(station: $1)
        }
    }
}
