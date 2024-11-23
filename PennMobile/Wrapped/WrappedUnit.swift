//
//  WrappedUnit.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//

import Foundation
import Lottie

public struct WrappedUnit: Identifiable, Hashable, Codable {
    public static func == (lhs: WrappedUnit, rhs: WrappedUnit) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Int
    let time: Double
    let lottie: LottieAnimation
    let values: [String:String]
    
    
    init(id: Int, time: TimeInterval?, lottie: LottieAnimation, values: [String:String] = [:]) {
        self.id = id
        self.time = time ?? lottie.duration
        self.lottie = lottie
        self.values = values
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
