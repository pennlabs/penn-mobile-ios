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

    init(pollQuestion: PollQuestion) {
        self.pollQuestion = pollQuestion
    }
    
    var pollQuestion: PollQuestion?
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let _ = item as? HomePollsCellItem else { return false }
        return true
    }
    
    static var jsonKey: String {
        return "polls"
    }
   
    static func getItem(for json: JSON?) -> HomeCellItem? {
//        guard let _ = json else { return nil }
//            return HomePollsCellItem()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let ddl = formatter.date(from:"2020/10/20 11:59")
        let pollOption1 = PollOption(id: 1, optionText: "Wharton Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption2 = PollOption(id: 2, optionText: "M&T Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption3 = PollOption(id: 3, optionText: "CIS Majors who are trying to transfer into Wharton", votes: 40, votesByYear: nil, votesBySchool: nil)
        let pollOption4 = PollOption(id: 4, optionText: "Armaan going to a Goldman info session", votes: 300, votesByYear: nil, votesBySchool: nil)

//        let pollQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)
        let pollQ = PollQuestion(title: "Who is more of a snake", source: "DP", ddl: "5/24", options: [pollOption1, pollOption2, pollOption3, pollOption4], optionChosenId: nil)

        return HomePollsCellItem(pollQuestion: pollQ)
    }
}

extension HomePollsCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        
    //    let formatter = DateFormatter()
    //    formatter.dateFormat = "yyyy-MM-dd"
    //
    //    let dateString = formatter.string(from: Date().roundedDownToHour)
    //
        PollsNetworkManager.instance.getActivePolls { (pollQuestions) in
            if let pollQuestions = pollQuestions {
                self.pollQuestion = pollQuestions.first
            }
            completion()
        }
    }
}
