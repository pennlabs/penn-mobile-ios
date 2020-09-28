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
        let ddl = formatter.date(from:"2020/10/01 11:59")
        let pollQuestion = PollQuestion(
            title: "Who is more of a snake?",
            source: "THE DAILY PENNSYLVANIAN",
            ddl: ddl,
            options:["Wharton Students":2,
                     "M&T Students":2,
                     "CIS Majors who are trying to transfer into Wharton": 6,
                     "Armaan going to a Goldman info session": 296])
        return HomePollsCellItem(pollQuestion:pollQuestion)
    }
}

