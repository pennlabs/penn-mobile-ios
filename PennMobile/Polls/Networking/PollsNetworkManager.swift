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
    let pollsURL = "https://api.pennlabs.org/api/polls"
    
    
    
    func getActivePolls(callback: @escaping ([PollQuestion]?) -> ()) {
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
//        let ddl = formatter.date(from:"2020/10/20 11:59")
//        let pollOption1 = PollOption(id: 1, optionText: "Wharton Students", votes: 20, votesByYear: nil, votesBySchool: nil)
//        let pollOption2 = PollOption(id: 2, optionText: "M&T Students", votes: 20, votesByYear: nil, votesBySchool: nil)
//        let pollOption3 = PollOption(id: 3, optionText: "CIS Majors who are trying to transfer into Wharton", votes: 40, votesByYear: nil, votesBySchool: nil)
//        let pollOption4 = PollOption(id: 4, optionText: "Armaan going to a Goldman info session", votes: 300, votesByYear: nil, votesBySchool: nil)
//
//        let pollQuestion = PollQuestion(title: "Who is more of a snake?", source: "The Daily Pennsylvanian", ddl: ddl!, options: [pollOption1, pollOption2, pollOption3, pollOption4], totalVoteCount: 380, optionChosenId: nil)
//
//        callback([pollQuestion])
        makeGetRequestWithAccessToken(url:pollsURL) { (data, response, error) in
                guard let data = data, error == nil  else {
                    callback(nil)
                    return
                }
                guard let pollstest = try? JSONDecoder().decode(PollsTest.self, from: data) else {
                    let jsonString = String(data: data, encoding: .utf8)
                    print(jsonString!)
                    callback(nil)
                    return
                }
                dump(pollstest)
                guard let polls = try? JSONDecoder().decode(Polls.self, from: data) else {
                    
                    let jsonString = String(data: data, encoding: .utf8)
                    print(jsonString!)
                    callback(nil)
                    return
                }
                    
            callback(polls.polls)
            }
        
    }
    
    /// TODO: Implement
    func getArchivedPolls(callback: @escaping ([PollQuestion]?) ->()) {
        return
    }
    
    func answerPoll(withId id: String, response: Int, callback: @escaping ( _ success: Bool, _ errorMsg: String?) -> ()) {
        return
    }
}

// MARK: TODO - General Networking Functions
extension PollsNetworkManager {
    fileprivate func makeGetRequestWithAccessToken(url: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            let url = URL(string: url)!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
            task.resume()
        }
    }
    
    fileprivate func makePostRequestWithAccessToken(url: String, params: [String: Any]?, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            let url = URL(string: url)!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "POST"
            if let params = params,
                let httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpBody = httpBody
            }
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
            task.resume()
        }
    }
}
