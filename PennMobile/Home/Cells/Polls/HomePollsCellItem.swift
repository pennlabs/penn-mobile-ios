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
    static var associatedCell: ModularTableViewCell.Type {
        return HomePollsCell.self
    }
    
    let pollQuestion: PollQuestion
    
    init(pollQuestion: PollQuestion) {
        self.pollQuestion = pollQuestion
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomePollsCellItem else { return false }
        return pollQuestion.title == item.pollQuestion.title
    }
    
    static var jsonKey: String {
        return "poll-question"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
       // guard let json = json else { return nil }
//        guard let pollQuestion = try? JSONDecoder().decode(PollQuestion.self, from: json.rawData()) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let ddl = formatter.date(from:"2020/10/20 11:59")
        let pollOption1 = PollOption(id: 1, optionText: "Wharton Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption2 = PollOption(id: 2, optionText: "M&T Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption3 = PollOption(id: 3, optionText: "CIS Majors who are trying to transfer into Wharton", votes: 40, votesByYear: nil, votesBySchool: nil)
        let pollOption4 = PollOption(id: 4, optionText: "Armaan going to a Goldman info session", votes: 300, votesByYear: nil, votesBySchool: nil)
        
        let pollQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)
        
        return HomePollsCellItem(pollQuestion:pollQuestion)
    }
}

