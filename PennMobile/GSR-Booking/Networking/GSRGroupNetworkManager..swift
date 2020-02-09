//
//  GSRGroupNetworking.swift
//
//
//  Created by Daniel Salib on 10/18/19.
//

import Foundation
import SwiftyJSON

class GSRGroupNetworkManager: NSObject, Requestable {
    // MARK: GSR Group Networking - Dummy Data for now
    static let instance = GSRGroupNetworkManager()
    
    let userURL = "https://studentlife.pennlabs.org/users/"
    let groupsURL = "https://studentlife.pennlabs.org/groups/"
    let membershipURL = "https://studentlife.pennlabs.org/membership/"
    let inviteURL = "https://studentlife.pennlabs.org/membership/invite/"
    
    
    
    func getAllGroups(callback: @escaping ([GSRGroup]?) -> ()) {
        guard let pennkey = Account.getAccount()?.pennkey else {
            print("User is not signed in")
            return
        }
        
        let allGroupsURL = "\(userURL)\(pennkey)/"
        
        makeGetRequestWithAccessToken(url: allGroupsURL) { (data, response, error) in
            if let error = error {
                print(error)
                callback(nil)
            } else if let data = data {
                let user = try? JSONDecoder().decode(GSRGroupUser.self, from: data)
                guard let guser = user else {
                    callback(nil)
                    return
                }
                callback(guser.groups)
            } else {
                callback(nil)
            }
        }
    }
    
    func getGroup(groupid: Int, callback: @escaping (_ errMessage: String?, _ group: GSRGroup?) -> ()) {
        
        let url = "\(groupsURL)\(groupid)/"
        
        makeGetRequestWithAccessToken(url: url) { (data, response, error) in
            if let error = error {
                callback(error.localizedDescription, nil)
            } else if let data = data {
                if let group = try? JSONDecoder().decode(GSRGroup.self, from: data) {
                    callback(nil, group)
                } else {
                    callback("group is nil", nil)
                }
                
            } else {
                callback("data is nil", nil)
            }
        }
    }
    
    func inviteUsers(groupID: Int, pennkeys: [String], callback: @escaping (Bool, Error?) -> ()) {
        let params: [String: Any] = ["group": groupID, "user": pennkeys.joined(separator: ",")]
        makePostRequestWithAccessToken(url: inviteURL, params: params) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, error)
                return
            }
            callback(status.statusCode == 200, error)
        }
    }
    
    func updateIndividualSetting(groupID: Int, settingType: GSRGroupIndividualSettingType, isEnabled: Bool, callback: @escaping (Bool, Error?) -> ()) {
        
        guard let pennkey = Account.getAccount()?.pennkey else {
            print("User is not signed in")
            return
        }
        
        var url = "\(membershipURL)"
        var params: [String: Any] = ["group": groupID, "user": pennkey]
        
        switch settingType {
        case .notificationsOn:
            url.append("notification/")
            params["active"] = isEnabled
        case .pennkeyActive:
            url.append("pennkey/")
            params["allow"] = isEnabled
        }
        
        makePostRequestWithAccessToken(url: url, params: params) { (data, response, error) in
            guard let status = response as? HTTPURLResponse else {
                callback(false, error)
                return
            }
            callback(status.statusCode == 200, error)
        }
    }
    
    func createGroup(name: String, color: String, callback: @escaping (_ success: Bool, _ groupID: Int?, _ errorMsg: String?) -> ()) {
        
        guard let pennkey = Account.getAccount()?.pennkey else {
            print("User is not signed in")
            callback(false, nil, "user is not signed in")
            return
        }
        
        let params: [String: Any] = ["owner": pennkey, "name": name, "color": color]
        makePostRequestWithAccessToken(url: groupsURL, params: params) { (data, status, error) in
            do {
                if let data = data,
                    let jsonDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? NSDictionary,
                    let groupID = jsonDict["id"] as? Int {
                    callback(true, groupID, nil)
                    
                } else {
                    callback(false, nil, "Couldn't read JSON response")
                }
            } catch {
                callback(false, nil, error.localizedDescription)
            }
        }
    }
    
    func getAllUsers(callback: @escaping (_ success: Bool, _ results: [GSRInviteSearchResult2]?) -> ()) {
        getRequestData(url: userURL) { (data, error, status) in
            guard let data = data else {
                callback(false, nil)
                return
            }
            
            let decoded = try? JSONDecoder().decode(GSRInviteSearchResults.self, from: data)
            
            guard let results = decoded else {
                callback(false, nil)
                return
            }
            
            callback(true, results)
            
        }
    }
}

extension GSRGroupNetworkManager {
    
    func getSearchResults(searchText:String, _ callback: @escaping (_ results: [GSRInviteSearchResult2]?) -> ()) {
        let urlStr = "http://api.pennlabs.org/studyspaces/user/search?query=\(searchText)"
        let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let resultsData = try? json["results"].rawData() {
                    let decoder = JSONDecoder()
                    let results = try? decoder.decode([GSRInviteSearchResult2].self, from: resultsData)
                    callback(results)
                    return
                }
            }
            callback(nil)
        }
        task.resume()
    }
}

// MARK: - General Networking Functions
extension GSRGroupNetworkManager {
    fileprivate func makeGetRequestWithAccessToken(url: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            print(token.value) //DELETE THIS LATER
            
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
