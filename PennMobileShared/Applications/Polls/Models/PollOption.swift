//
//  PollOption.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct PollOption: Codable, Identifiable, Sendable {
    public let id: Int
    public let poll: Int
    public let choice: String
    public var voteCount: Int
}
