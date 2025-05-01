//
//  WrappedUnit.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//

import Foundation
import Lottie

public struct WrappedUnit: Identifiable, Hashable, Decodable {
    public static func == (lhs: WrappedUnit, rhs: WrappedUnit) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Int
    var time: TimeInterval?
    let lottieUrl: URL
    private(set) var lottie: LottieAnimation? = nil
    let values: [String:String]
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        let durationString = try? container.decode(String.self, forKey: .time)
        self.time = durationString != nil ? WrappedUnit.timeInterval(from: durationString!) : nil
        self.lottieUrl = try container.decode(URL.self, forKey: .lottieUrl)
        self.values = try container.decode([String : String].self, forKey: .values)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case lottieUrl = "template_path"
        case values = "combined_stats"
        case time = "duration"
    }
    
    @discardableResult mutating func loadAnimation() async -> Bool {
        let val = await LottieAnimation.loadedFrom(url: self.lottieUrl)
        guard let anim = await LottieAnimation.loadedFrom(url: lottieUrl) else {
            return false
        }
        
        if self.time == nil {
            self.time = anim.duration
        }
        self.lottie = anim
        return true
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

extension LottieAnimation: @retroactive Hashable {
    public static func == (lhs: Lottie.LottieAnimation, rhs: Lottie.LottieAnimation) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
