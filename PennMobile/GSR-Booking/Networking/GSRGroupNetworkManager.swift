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
    
    fileprivate static let labs = GSRGroup(id: "1", name: "Penn Labs 😈", imgURL: nil, color: "blue", owners: nil, members: nil, createdAt: Date(), isActive: true, reservations: nil)
    fileprivate static let cis121 = GSRGroup(id: "2", name: "CIS 121 Study Group", imgURL: nil, color: "green", owners: nil, members: nil, createdAt: Date(), isActive: true, reservations: nil)
    fileprivate static let cis160 = GSRGroup(id: "3", name: "CIS 160 Study Group", imgURL: nil, color: "red", owners: nil, members: nil, createdAt: Date(), isActive: true, reservations: nil)
    
    fileprivate var groups: [GSRGroup] = [labs, cis121, cis160]
    
    fileprivate func getDummyUsers() -> [GSRGroupMember] {
        let daniel = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Daniel", last: "Salib", email: "dsalib@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let rehaan = GSRGroupMember(accountID: "1", pennKey: "rehaan", first: "Rehaan", last: "Furniturewala", email: "rehaan@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let lucy = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Lucy", last: "Yuan", email: "yuewei@seas.upenn.edu", isBookingEnabled: false, isAdmin: false)
        return [daniel, rehaan, lucy]
    }

    func getAllGroups(callback: ([GSRGroup]?) -> ()) {
        callback(groups)
    }
    
    func getGroup(groupid: String, callback: (GSRGroup?) -> ()) {
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
    //GSRGroup(id: "new", name: nameField.text!, imgURL: nil, color: "color", owners: [GSRGroupMember(accountID: "dummyOwner", pennKey: "dummyPennKey", first: "DummyF", last: "DummyL", email: "yuewei@seas.upenn.edu", isBookingEnabled: true, isAdmin: true)], members: [], createdAt: Date(), isActive: true, reservations: [])
    
    func createGroup(name: String, color: String, callback: (_ success: Bool, _ errorMsg: String?) -> ()) {
        let dummyUsers = getDummyUsers()
        let group = GSRGroup(id: name, name: name, imgURL: nil, color: color, owners: [dummyUsers[0]], members: dummyUsers, createdAt: Date(), isActive: true, reservations: nil)
        groups.append(group)
        
        callback(true, nil)
    }
    
    
    
}
