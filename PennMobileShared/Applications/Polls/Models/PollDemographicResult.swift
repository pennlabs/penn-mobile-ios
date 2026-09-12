//
//  PollDemographicResult.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

public struct PollDemographicResult: Codable, Sendable {
    public let demographic: String
    public let votes: Int
}
