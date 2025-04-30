//
//  WrappedAPIUnit.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import Lottie
import SwiftyJSON

public struct WrappedAPIUnit: Identifiable, Codable {
    public static func == (lhs: WrappedAPIUnit, rhs: WrappedAPIUnit) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Int
    let time: TimeInterval?
    let lottieUrl: URL
    let values: [String:String]
    let name: String
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let durationString = try container.decodeIfPresent(String.self, forKey: .time)
        self.id = try container.decode(Int.self, forKey: .id)
        self.time = durationString != nil ? WrappedAPIUnit.timeInterval(from: durationString!) : nil
        self.name = try container.decode(String.self, forKey: .name)
        self.lottieUrl = try container.decode(URL.self, forKey: .lottieUrl)
        self.values = try container.decode([String : String].self, forKey: .values)
        
    }
    
    static func timeInterval(from timeString: String) -> TimeInterval? {
        let components = timeString.split(separator: ":").compactMap { Double($0) }
        guard components.count == 3 else { return nil }
        let hours = components[0]
        let minutes = components[1]
        let seconds = components[2]
        return (hours * 3600) + (minutes * 60) + seconds
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case lottieUrl = "template_path"
        case values = "combined_stats"
        case time = "duration"

    }
}
