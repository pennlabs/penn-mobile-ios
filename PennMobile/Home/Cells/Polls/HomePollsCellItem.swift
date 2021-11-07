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
    
    var pollQuestion: PollQuestion
    
    init(pollQuestion: PollQuestion) {
        self.pollQuestion = pollQuestion
    }
    
    
    
    func equals(item: ModularTableViewItem) -> Bool {
//        guard let item = item as? HomePollsCellItem else { return false }
//        return pollQuestion.title == item.pollQuestion.title
        guard let _ = item as? HomePollsCellItem else { return false }
        return true
    }
    
    static var jsonKey: String {
        return "polls"
    }
    
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
//        guard let _ = json else { return nil }
//        return HomePollsCellItem()
        
       // guard let json = json else { return nil }
//        guard let pollQuestion = try? JSONDecoder().decode(PollQuestion.self, from: json.rawData()) else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let ddl = formatter.date(from:"2021/12/20 11:59")
        let pollOption1 = PollOption(id: 1, optionText: "Wharton Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption2 = PollOption(id: 2, optionText: "M&T Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption3 = PollOption(id: 3, optionText: "CIS Majors who are trying to transfer into Wharton", votes: 40, votesByYear: nil, votesBySchool: nil)
        let pollOption4 = PollOption(id: 4, optionText: "Armaan going to a Goldman info session", votes: 300, votesByYear: nil, votesBySchool: nil)
        
        let dummyQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)
        return HomePollsCellItem(pollQuestion:dummyQuestion)
        
    }
    
}

// MARK: - JSON Parsing
//TODO: Add real JSON Parsing
extension HomePollsCellItem {
    convenience init(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let ddl = formatter.date(from:"2021/12/20 11:59")
        let pollOption1 = PollOption(id: 1, optionText: "dummy1", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption2 = PollOption(id: 2, optionText: "dummy2", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption3 = PollOption(id: 3, optionText: "dummy3", votes: 40, votesByYear: nil, votesBySchool: nil)
        let pollOption4 = PollOption(id: 4, optionText: "dummy4", votes: 300, votesByYear: nil, votesBySchool: nil)
        
        let dummyQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)
        
        var pollQuestion = dummyQuestion
        PollsNetworkManager.instance.getActivePolls { (pollQuestions) in
            if let pollQuestions = pollQuestions {
                pollQuestion = pollQuestions.first ?? dummyQuestion
            }
        }
        self.init(pollQuestion:pollQuestion)

    }
}

//not called anywhere yet
extension HomePollsCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {

    //    let formatter = DateFormatter()
    //    formatter.dateFormat = "yyyy-MM-dd"
    //
    //    let dateString = formatter.string(from: Date().roundedDownToHour)
    //
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let ddl = formatter.date(from:"2021/12/20 11:59")
        let pollOption1 = PollOption(id: 1, optionText: "dummy1", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption2 = PollOption(id: 2, optionText: "dummy2", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption3 = PollOption(id: 3, optionText: "dummy3", votes: 40, votesByYear: nil, votesBySchool: nil)
        let pollOption4 = PollOption(id: 4, optionText: "dummy4", votes: 300, votesByYear: nil, votesBySchool: nil)
        
        let dummyQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)
        PollsNetworkManager.instance.getActivePolls { (pollQuestions) in
            if let pollQuestions = pollQuestions {
                self.pollQuestion = pollQuestions.first ?? dummyQuestion
            }
            completion()
        }
    }
}


