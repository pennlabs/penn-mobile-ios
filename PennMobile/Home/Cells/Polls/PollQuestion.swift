//
//  PollQuestion.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

class PollQuestion {
    let title: String?
    let source: String?
    let ddl: Date?
    let options: [String:Int]?
    let totalVoteCount: Int?
    let userChosen: String?

    init(title: String?, source: String?, ddl: Date?, options: [String:Int], totalVoteCount: Int) {
        self.title = title
        self.source = source
        self.ddl = ddl
        self.options = options
        self.totalVoteCount = totalVoteCount
        self.userChosen = "Armaan going to a Goldman info session"
    }
}
