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


//    fileprivate static let pennKeyActiveSetting = GSRGroupIndividualSetting(title: "PennKey Permission", descr: "Anyone in this group can book a study room block using your PennKey.", isEnabled: false)
//    fileprivate static let notificationOnSetting = GSRGroupIndividualSetting(title: "Notifications", descr: "You’ll receive a notification any time a room is booked by this group.", isEnabled: false)
//    
//    fileprivate static let userSettings = GSRGroupIndividualSettings(pennKeyActive: pennKeyActiveSetting, notificationsOn: notificationOnSetting)
//    fileprivate static let groupSettings = GSRGroupAccessSettings(booking: .everyone, invitation: .everyone)
//
//    fileprivate static let labs = GSRGroup(id: 1, name: "Penn Labs", color: "Cheeto Orange", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)
//    fileprivate static let cis121 = GSRGroup(id: 2, name: "CIS 121 Study Group", color: "blue", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)
//    fileprivate static let cis160 = GSRGroup(id: 3, name: "CIS 160 Study Group", color: "blue", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)
//
//    fileprivate var groups: [GSRGroup] = [labs, cis121, cis160]
//
//    fileprivate func getDummyUsers() -> [GSRGroupMember] {
//        let daniel = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Daniel", last: "Salib", email: "dsalib@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
//        let rehaan = GSRGroupMember(accountID: "1", pennKey: "rehaan", first: "Rehaan", last: "Furniturewala", email: "rehaan@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
//        let lucy = GSRGroupMember(accountID: "1", pennKey: "yuewei", first: "Lucy", last: "Yuan", email: "yuewei@seas.upenn.edu", isBookingEnabled: false, isAdmin: false)
//        return [daniel, rehaan, lucy]
//    }




    func getAllGroups(callback: @escaping ([GSRGroup]?) -> ()) {
        let allGroupsURL = "\(userURL)me/"

        makeGetRequestWithAccessToken(url: allGroupsURL) { (data, response, error) in
            guard let data = data, error == nil  else {
                callback(nil)
                return
            }

            guard let user = try? JSONDecoder().decode(GSRGroupUser.self, from: data) else {
                callback(nil)
                return
            }

            callback(user.groups)
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

    func getAllUsers(callback: @escaping (_ success: Bool, _ results: [GSRInviteSearchResult]?) -> ()) {
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

    func getInvites(callback: @escaping (_ success: Bool, _ invites: [GSRGroupInvite], _ error: Error?) -> ()) {
        var invites = GSRGroupInvites()
        guard let pennkey = Account.getAccount()?.pennkey else {
            print("User is not signed in")
            callback(false, invites, nil)
            return
        }

        let url = "\(userURL)\(pennkey)/invites/"

        makeGetRequestWithAccessToken(url: url) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, invites, error)
                return
            }

            if error != nil || status.statusCode != 200 {
                callback(false, invites, error)
                return
            }

            guard let data = data else {
                callback(false, invites, error)
                return
            }

            let decoded = try? JSONDecoder().decode(GSRGroupInvites.self, from: data)

            guard let results = decoded else {
                callback(false, invites, error)
                return
            }

            invites = results
            callback(true, invites, error)
        }
    }

    func respondToInvite(invite: GSRGroupInvite, accept: Bool, callback: @escaping (_ success: Bool) -> ()) {
        let params = [String: Any]()
        makePostRequestWithAccessToken(url: "\(membershipURL)\(invite.id)/\(accept ? "accept" : "decline")/", params: params) { (data, status, error) in

            guard let status = status as? HTTPURLResponse else {
                callback(false)
                return
            }

            callback(status.statusCode == 200)
        }
    }
}

extension GSRGroupNetworkManager {
    func getSearchResults(searchText:String, _ callback: @escaping (_ results: [GSRInviteSearchResult]?) -> ()) {
        let urlStr = "http://api.pennlabs.org/studyspaces/user/search?query=\(searchText)"
        let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let resultsData = try? json["results"].rawData() {
                    let decoder = JSONDecoder()
                    let results = try? decoder.decode([GSRInviteSearchResult].self, from: resultsData)
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
