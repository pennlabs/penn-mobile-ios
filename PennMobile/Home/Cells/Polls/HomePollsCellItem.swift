//
//  HomePollsCellItem.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomePollsCellItem: HomeCellItem {
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let ddl = formatter.date(from:"2021/12/20 11:59")
        let pollOption1 = PollOption(id: 1, optionText: "Wharton Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption2 = PollOption(id: 2, optionText: "M&T Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption3 = PollOption(id: 3, optionText: "CIS Majors who are trying to transfer into Wharton", votes: 40, votesByYear: nil, votesBySchool: nil)
        let pollOption4 = PollOption(id: 4, optionText: "Armaan going to a Goldman info session", votes: 300, votesByYear: nil, votesBySchool: nil)

        let dummyQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)
        completion([HomePollsCellItem(pollQuestion:dummyQuestion)])
    }

    static var associatedCell: ModularTableViewCell.Type {
        return HomePollsCell.self
    }

    var pollQuestion: PollQuestion

    init(pollQuestion: PollQuestion) {
        self.pollQuestion = pollQuestion
    }

    func equals(item: ModularTableViewItem) -> Bool {
        return true
    }

    static var jsonKey: String {
        return "polls"
    }
}


