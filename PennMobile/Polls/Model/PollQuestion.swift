//
//  PollQuestion.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PollDemographicResult: Codable {
    let demographic: String
    let votes: Int
}

struct PollOption: Codable, Identifiable {
    let id: Int
    let poll: Int
    let choice: String
    var voteCount: Int
}

struct PollQuestion: Codable, Identifiable {
    let id: Int
    let question: String
    let clubCode: String
    let createdDate: Date
    let startDate: Date
    let expireDate: Date
    let multiselect: Bool
    let clubComment: String?
    var options: [PollOption]
    var totalVoteCount: Int {
        options.reduce(0, { $0 + $1.voteCount })
    }
    var optionChosenId: Int?
    
    static let mock = PollQuestion(
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
            .init(id: 3, poll: 234, choice: "This is a really long answer that is meant to test the limits of line wrapping with polls. Hopefully there are no bugs that come from this.", voteCount: 300),
        ],
        optionChosenId: 3
    )
}

struct PollPost: Codable {
    let id: Int
    let idHash: String
    let poll: PollQuestion
    let pollOptions: [PollOption]
    //let createdDate: Date
}
