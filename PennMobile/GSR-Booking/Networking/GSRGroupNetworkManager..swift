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

    fileprivate static let pennKeyActiveSetting = GSRGroupIndividualSetting(title: "PennKey Permission", descr: "Anyone in this group can book a study room block using your PennKey.", isEnabled: false)
    fileprivate static let notificationOnSetting = GSRGroupIndividualSetting(title: "Notifications", descr: "You’ll receive a notification any time a room is booked by this group.", isEnabled: false)

    fileprivate static let userSettings = GSRGroupIndividualSettings(pennKeyActive: pennKeyActiveSetting, notificationsOn: notificationOnSetting)
    fileprivate static let groupSettings = GSRGroupAccessSettings(booking: .everyone, invitation: .everyone)

    fileprivate static let labs = GSRGroup(id: 1, name: "Penn Labs", color: "Cheeto Orange", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)
    fileprivate static let cis121 = GSRGroup(id: 2, name: "CIS 121 Study Group", color: "blue", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)
    fileprivate static let cis160 = GSRGroup(id: 3, name: "CIS 160 Study Group", color: "blue", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)

    fileprivate var groups: [GSRGroup] = [labs, cis121, cis160]

    fileprivate func getDummyUsers() -> [GSRGroupMember] {
        let daniel = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Daniel", last: "Salib", email: "dsalib@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let rehaan = GSRGroupMember(accountID: "1", pennKey: "rehaan", first: "Rehaan", last: "Furniturewala", email: "rehaan@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let lucy = GSRGroupMember(accountID: "1", pennKey: "yuewei", first: "Lucy", last: "Yuan", email: "yuewei@seas.upenn.edu", isBookingEnabled: false, isAdmin: false)
        return [daniel, rehaan, lucy]
    }



    func getAllGroups(callback: @escaping ([GSRGroup]?) -> ()) {
        // handle missing pennkey later
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
                print(guser)
                callback(guser.groups)
            } else {
                callback(nil)
            }
        }
    }

    func getGroup(groupid: Int, callback: (GSRGroup?) -> ()) {
        let group = groups.first { (group) -> Bool in
            return group.id == groupid
        }

        if var group = group {
            let dummyUsers = getDummyUsers()
            group.members = dummyUsers
            group.owners = [dummyUsers[0]]
            callback(group)
        } else {
            callback(nil)
        }
    }



    func inviteUser(groupid: Int, pennkey: String, callback: @escaping (Bool) -> ()) {
        let params: [NSString: Any] = ["group": groupid, "username": pennkey]
        postRequestData(url: membershipURL, params: params) { (data, err, status) in
            callback(status == 200 && err == nil)
        }
    }

    func inviteUsers(groupid: Int, pennkeys: [String], callback: @escaping (Bool) -> ()) {
        let params: [NSString: Any] = ["group": groupid, "username": pennkeys]
        postRequestData(url: membershipURL, params: params) { (data, err, status) in
            callback(status == 200 && err == nil)
        }
    }

    func createGroup(name: String, color: String, callback: @escaping (_ success: Bool, _ errorMsg: String?) -> ()) {

        guard let pennkey = Account.getAccount()?.pennkey else {
            print("User is not signed in")
            callback(false, "user is not signed in")
            return
        }

        let params: [String: Any] = ["owner": pennkey, "name": name, "color": color]
        makePostRequestWithAccessToken(url: groupsURL, params: params) { (data, status, error) in
            if let error = error {
                callback(false, error.localizedDescription)
            } else {
                callback(true, nil)
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




}

extension GSRGroupNetworkManager {

    func getSearchResults(searchText:String, _ callback: @escaping (_ results: [GSRInviteSearchResult2]?) -> ()) {
        let urlStr = "http://api.pennlabs.org/studyspaces/user/search?query=\(searchText)"
        let url = URL(string: urlStr)!
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
            if let params = params {
                request.httpBody = String.getPostString(params: params).data(using: .utf8)
            }

            let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
            task.resume()
        }
    }
}