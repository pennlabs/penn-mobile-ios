//
//  GSRTimeSlot.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import SwiftUI

public struct GSRTimeSlot: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id = UUID()
    public let startTime: Date
    public let endTime: Date
    public var isAvailable: Bool = true

    enum CodingKeys: CodingKey {
        case startTime
        case endTime
    }
    
    public var color: Color {
        isAvailable ? Color("gsrAvailable") : Color("gsrUnavailable")
    }
}
