//
//  WrappedUnit.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public struct WrappedUnit: Identifiable, Hashable, Decodable, Sendable {
    public static func == (lhs: WrappedUnit, rhs: WrappedUnit) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Int
    public var time: TimeInterval?
    public let lottieUrl: URL
    public let values: [String: String]
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        let durationString = try? container.decode(String.self, forKey: .time)
        self.time = durationString.flatMap { WrappedUnit.timeInterval(from: $0) }
        self.lottieUrl = try container.decode(URL.self, forKey: .lottieUrl)
        self.values = try container.decode([String: String].self, forKey: .values)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case lottieUrl = "template_path"
        case values = "combined_stats"
        case time = "duration"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func timeInterval(from timeString: String) -> TimeInterval? {
        let components = timeString.split(separator: ":").compactMap { Double($0) }
        guard components.count == 3 else { return nil }
        let hours = components[0]
        let minutes = components[1]
        let seconds = components[2]
        return (hours * 3600) + (minutes * 60) + seconds
    }
}
