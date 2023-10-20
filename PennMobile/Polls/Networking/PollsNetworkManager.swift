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

class PollsNetworkManager: NSObject, Requestable, SHA256Hashable {
    static let id = UIDevice.current.identifierForVendor?.uuidString ?? ""
    static let instance = PollsNetworkManager()
    let pollURL = URL(string: "https://pennmobile.org/api/portal/polls/browse/")
    let votesURL = URL(string: "https://pennmobile.org/api/portal/votes/")
    let recentsURL = URL(string: "https://pennmobile.org/api/portal/votes/recent/")
    let allVotesURL = URL(string: "https://pennmobile.org/api/portal/votes/all/")
    
    func getPollHistory() async -> Result<[PollPost], NetworkingError> {
        if let token = await OAuth2NetworkManager.instance.getAccessTokenAsync() {
            var request = URLRequest(url: self.allVotesURL!, accessToken: token)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try? JSONSerialization.data(withJSONObject: ["id_hash": hash(string: PollsNetworkManager.id, encoding: .base64)])
            request.httpBody = jsonData
            request.httpMethod = "POST"
            
            guard let (data, _) = try? await URLSession.shared.data(for: request) else {
                return .failure(.serverError)
            }
            
            if let polls = try? JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([PollPost].self, from: data) {
                return .success(polls)
            } else {
                return .failure(.parsingError)
            }
        } else {
            return .failure(.serverError)
        }
    }

    func getActivePolls() async -> Result<[PollQuestion], NetworkingError> {
        if let token = await OAuth2NetworkManager.instance.getAccessTokenAsync() {
            var request = URLRequest(url: self.pollURL!, accessToken: token)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try? JSONSerialization.data(withJSONObject: ["id_hash": hash(string: PollsNetworkManager.id, encoding: .base64)])
            request.httpBody = jsonData
            request.httpMethod = "POST"
            
            guard let (data, _) = try? await URLSession.shared.data(for: request) else {
                return .failure(.serverError)
            }
            
            if let polls = try? JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([PollQuestion].self, from: data) {
                return .success(polls)
            } else {
                return .failure(.parsingError)
            }
        } else {
            return .failure(.serverError)
        }
    }

    func getArchivedPolls() async -> Result<[PollQuestion], NetworkingError> {
        if let token = await OAuth2NetworkManager.instance.getAccessTokenAsync() {
            var request = URLRequest(url: self.recentsURL!, accessToken: token)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try? JSONSerialization.data(withJSONObject: ["id_hash": hash(string: PollsNetworkManager.id, encoding: .base64)])
            request.httpBody = jsonData
            request.httpMethod = "POST"
            
            guard let (data, _) = try? await URLSession.shared.data(for: request) else {
                return .failure(.serverError)
            }
            
            if let polls = try? JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([PollQuestion].self, from: data) {
                return .success(polls)
            } else {
                return .failure(.parsingError)
            }
        } else {
            return .failure(.serverError)
        }
    }

    func answerPoll(withId id: String, response: Int) async -> Bool {
        if let token = await OAuth2NetworkManager.instance.getAccessTokenAsync() {
            var request = URLRequest(url: self.votesURL!, accessToken: token)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try? JSONSerialization.data(withJSONObject: ["id_hash": hash(string: id, encoding: .base64), "poll_options": [response]] as [String: Any])
            request.httpBody = jsonData
            request.httpMethod = "POST"

            guard let (data, response) = try? await URLSession.shared.data(for: request) else {
                return false
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print(JSON(data))
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
