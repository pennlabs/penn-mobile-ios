//
//  PollsNetworkManager.swift
//  PennMobile
//
//  Created by Justin Lieb on 11/15/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class PollsNetworkManager: NSObject, Requestable {

    static let instance = PollsNetworkManager()
    let pollsURL = "https://studentlife.pennlabs.org/polls/"
    let optionsURL = "https://studentlife.pennlabs.org/options/"
    let votesURL = "https://studentlife.pennlabs.org/votes/"

    func getActivePolls(callback: @escaping ([PollQuestion]?) -> ()) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let ddl = formatter.date(from:"2020/10/20 11:59")
        let pollOption1 = PollOption(id: 1, optionText: "Wharton Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption2 = PollOption(id: 2, optionText: "M&T Students", votes: 20, votesByYear: nil, votesBySchool: nil)
        let pollOption3 = PollOption(id: 3, optionText: "CIS Majors who are trying to transfer into Wharton", votes: 40, votesByYear: nil, votesBySchool: nil)
        let pollOption4 = PollOption(id: 4, optionText: "Armaan going to a Goldman info session!", votes: 300, votesByYear: nil, votesBySchool: nil)

        let pollQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)

        callback([pollQuestion])
    }

    /// TODO: Implement
    func getArchivedPolls(callback: @escaping ([PollQuestion]?) ->()) {
        return
    }

    func answerPoll(withId id: String, response: Int, callback: @escaping ( _ success: Bool, _ errorMsg: String?) -> ()) {
        return
    }
}
