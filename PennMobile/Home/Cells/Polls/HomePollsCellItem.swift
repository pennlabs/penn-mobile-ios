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

        PollsNetworkManager.instance.getActivePolls { polls in
            if let polls = polls, polls.count > 0 {
                completion([HomePollsCellItem(pollQuestion: polls[0])])
            } else {
                completion([])
            }
        }
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
