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

struct PollOption: Codable {
    let id: Int
    let poll: Int
    let choice: String
    var voteCount: Int
}

struct PollQuestion: Codable {
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
}

struct PollPost: Codable {
    let id: Int
    let idHash: UUID
    let poll: PollQuestion
    let pollOptions: [PollOption]
    //let createdDate: Date
}
