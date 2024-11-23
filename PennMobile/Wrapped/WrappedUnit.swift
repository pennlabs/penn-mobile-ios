//
//  WrappedUnit.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/25/24.
//

import Foundation
import Lottie

public struct WrappedUnit: Identifiable, Hashable {
    public static func == (lhs: WrappedUnit, rhs: WrappedUnit) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Int
    let time: TimeInterval
    let lottie: LottieAnimation
    let values: [String:String]
    
    
    init(id: Int, time: TimeInterval?, lottie: LottieAnimation, values: [String:String] = [:]) {
        self.id = id
        self.time = time ?? lottie.duration
        self.lottie = lottie
        self.values = values
    }
    
    init(from apiUnit: WrappedAPIUnit, id: Int) async throws {
        self.id = id
        guard let anim = await LottieAnimation.loadedFrom(url: apiUnit.lottieUrl) else {
            throw DecodingError.valueNotFound(WrappedUnit.self, DecodingError.Context(codingPath: [], debugDescription: "Could not load animation from \(apiUnit.lottieUrl)"))
        }
        self.lottie = anim
        self.time = apiUnit.time ?? anim.duration
        self.values = apiUnit.values
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
