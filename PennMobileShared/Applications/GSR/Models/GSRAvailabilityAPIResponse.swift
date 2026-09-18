//
//  GSRAvailabilityAPIResponse.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/9/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

public struct GSRAvailabilityAPIResponse: Codable, Sendable {
    public let name: String
    public let gid: Int
    public let rooms: [GSRRoom]
}
