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
    let optionText: String
    let votes: Int
    let votesByYear: [PollDemographicResult]?
    let votesBySchool: [PollDemographicResult]?
}

struct PollQuestion: Codable {
    let title: String
    let source: String
    let ddl: Date
    let options: [PollOption]
    let totalVoteCount: Int
    var optionChosenId: Int?

    enum CodingKeys: String, CodingKey {
        case title = "question"
        case source = "orgAuthor"
        case ddl = "expiration"
        case options, totalVoteCount, optionChosenId
    }

}
