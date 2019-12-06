//
//  GSRGroupNetworking.swift
//
//
//  Created by Daniel Salib on 10/18/19.
//

import Foundation

class GSRGroupNetworkManager: NSObject, Requestable {
    // MARK: GSR Group Networking - Dummy Data for now
    static let instance = GSRGroupNetworkManager()

    let userURL = "https://gsr.upenn.club/users/"
    let groupsURL = "https://gsr.upenn.club/groups/"
    let membershipURL = "https://gsr.upenn.club/membership/"

    fileprivate static let pennKeyActiveSetting = GSRGroupIndividualSetting(title: "PennKey Permission", descr: "Anyone in this group can book a study room block using your PennKey.", isEnabled: false)
    fileprivate static let notificationOnSetting = GSRGroupIndividualSetting(title: "Notifications", descr: "You’ll receive a notification any time a room is booked by this group.", isEnabled: false)

    fileprivate static let userSettings = GSRGroupIndividualSettings(pennKeyActive: pennKeyActiveSetting, notificationsOn: notificationOnSetting)
    fileprivate static let groupSettings = GSRGroupAccessSettings(booking: .everyone, invitation: .everyone)

    fileprivate static let labs = GSRGroup(id: 1, name: "Penn Labs", color: "blue", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)
    fileprivate static let cis121 = GSRGroup(id: 2, name: "CIS 121 Study Group", color: "blue", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)
    fileprivate static let cis160 = GSRGroup(id: 3, name: "CIS 160 Study Group", color: "blue", createdAt: Date(), userSettings: userSettings, imgURL: nil, owners: nil, members: nil, reservations: nil, groupSettings: groupSettings)

    fileprivate var groups: [GSRGroup] = [labs, cis121, cis160]

    fileprivate func getDummyUsers() -> [GSRGroupMember] {
        let daniel = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Daniel", last: "Salib", email: "dsalib@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let rehaan = GSRGroupMember(accountID: "1", pennKey: "rehaan", first: "Rehaan", last: "Furniturewala", email: "rehaan@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let lucy = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Lucy", last: "Yuan", email: "yuewei@seas.upenn.edu", isBookingEnabled: false, isAdmin: false)
        return [daniel, rehaan, lucy]
    }

    func getAllGroups(callback: @escaping ([GSRGroup]?) -> ()) {
        // handle missing pennkey later
        guard let pennkey = Student.getStudent()?.pennkey else {
            print("Use is not signed in")
            return
        }

        let allGroupsURL = "\(userURL)\(pennkey)/"
        getRequestData(url: allGroupsURL) { (data, error, status) in
            guard let data = data else { return }
            let user = try? JSONDecoder().decode(GSRGroupUser.self, from: data)

            guard let guser = user else {
                callback(nil)
                return
            }

            callback(guser.groups)
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
    //GSRGroup(id: "new", name: nameField.text!, imgURL: nil, color: "color", owners: [GSRGroupMember(accountID: "dummyOwner", pennKey: "dummyPennKey", first: "DummyF", last: "DummyL", email: "yuewei@seas.upenn.edu", isBookingEnabled: true, isAdmin: true)], members: [], createdAt: Date(), isActive: true, reservations: [])

//    func createGroup(name: String, color: String, callback: (_ success: Bool, _ errorMsg: String?) -> ()) {
//        let dummyUsers = getDummyUsers()
//        let groupSettings = GSRGroupAccessSettings(booking: .everyone, invitation: .everyone)
//        let group = GSRGroup(id: 1, name: name, color: color, createdAt: Date(), userSettings: GSRGroupNetworkManager.userSettings, imgURL: nil, owners: [dummyUsers[0]], members: dummyUsers, reservations: nil, groupSettings: groupSettings)
//        groups.append(group)
//
//        callback(true, nil)
//    }
    func createGroup(name: String, color: String, callback: @escaping (_ success: Bool, _ errorMsg: String?) -> ()) {

        guard let pennkey = Student.getStudent()?.pennkey else {
            print("User is not signed in")
            callback(false, "user is not signed in")
            return
        }

        let params: [NSString: Any] = ["owner": pennkey, "name": name, "color": color]
        postRequestData(url: groupsURL, params: params) { (data, error, status) in
            if let error = error {
                print("postRequest Error: \(error)")
                callback(false, error.localizedDescription)
            }

            print(status)

            callback(true, nil)
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
