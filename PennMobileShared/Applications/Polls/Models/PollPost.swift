//
//  PollPost.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct PollPost: Codable, Sendable {
    public let id: Int
    public let idHash: String
    public let poll: PollQuestion
    public let pollOptions: [PollOption]
}
