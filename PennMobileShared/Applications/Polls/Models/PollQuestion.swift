//
//  PollQuestion.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

public struct PollQuestion: Codable, Identifiable, Sendable {
    public let id: Int
    public let question: String
    public let clubCode: String
    public let createdDate: Date
    public let startDate: Date
    public let expireDate: Date
    public let multiselect: Bool
    public let clubComment: String?
    public var options: [PollOption]
    public var totalVoteCount: Int {
        options.reduce(0, { $0 + $1.voteCount })
    }
    public var optionChosenId: Int?
    
    public static let mock = PollQuestion(
        id: 234,
        question: "Question",
        clubCode: "pennlabs",
        createdDate: Date(),
        startDate: Date(),
        expireDate: .distantFuture,
        multiselect: false,
        clubComment: nil,
        options: [
            .init(id: 1, poll: 234, choice: "Answer 1", voteCount: 1),
            .init(id: 2, poll: 234, choice: "Answer 2", voteCount: 200),
            .init(id: 3, poll: 234, choice: "This is a really long answer that is meant to test the limits of line wrapping with polls. Hopefully there are no bugs that come from this.", voteCount: 300)
        ],
        optionChosenId: 3
    )
}
