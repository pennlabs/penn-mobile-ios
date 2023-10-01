//
//  PollsNetworkManager.swift
//  PennMobile
//
//  Created by Justin Lieb on 11/15/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import PennMobileShared

class PollsNetworkManager: NSObject, Requestable {

    static let id = UIDevice.current.identifierForVendor?.uuidString ?? ""
    static let instance = PollsNetworkManager()
    let pollURL = URL(string: "https://pennmobile.org/api/portal/polls/browse/")
    let votesURL = URL(string: "https://pennmobile.org/api/portal/votes/")
    let recentsURL = URL(string: "https://pennmobile.org/api/portal/votes/recent/")

    func getActivePolls(callback: @escaping ([PollQuestion]?) -> Void) {

        OAuth2NetworkManager.instance.getAccessToken { (token) in
        guard let token = token else {
           print("couldn't get token!")
               callback(nil)
               return
           }
            var request = URLRequest(url: self.pollURL!, accessToken: token)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try? JSONSerialization.data(withJSONObject: ["id_hash": PollsNetworkManager.id])
            request.httpBody = jsonData
            request.httpMethod = "POST"

            let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                if let data, let polls = try? JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([PollQuestion].self, from: data) {
                    callback(polls)
                } else {
                    callback([])
                }
            }
            task.resume()
       }
    }

    func getArchivedPolls(callback: @escaping ([PollQuestion]?) -> Void) {

        OAuth2NetworkManager.instance.getAccessToken { (token) in
        guard let token = token else {
            callback(nil)
            return
        }
            var request = URLRequest(url: self.recentsURL!, accessToken: token)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try? JSONSerialization.data(withJSONObject: ["id_hash": "aaa"])
            request.httpBody = jsonData
            request.httpMethod = "POST"

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do { let test = try JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([PollQuestion].self, from: data!)
                    callback(test) } catch {
                    print(error)
                }
            }
            task.resume()
        }
        return
    }

    func answerPoll(withId id: String, response: Int, callback: @escaping ( _ success: Bool) -> Void) {

        OAuth2NetworkManager.instance.getAccessToken { (token) in
        guard let token = token else {
            callback(false)
            return
        }
            var request = URLRequest(url: self.votesURL!, accessToken: token)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try? JSONSerialization.data(withJSONObject: ["id_hash": id, "poll_options": [response]])
            request.httpBody = jsonData
            request.httpMethod = "POST"

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201, let data = data {
                    print(JSON(data))
                    callback(true)
                } else {
                    callback(false)
                }
            }
            task.resume()
        }

     }
}
