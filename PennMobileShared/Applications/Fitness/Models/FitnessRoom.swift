//
//  FitnessRoom.swift
//  PennMobile
//
//  Created by Jordan H on 4/7/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation

public struct FitnessRoom: Codable, Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let image_url: URL?
    public let last_updated: Date
    public let count: Int
    public var capacity: Double
    public let open: [String]
    public let close: [String]
    public var data: FitnessRoomData?
}
