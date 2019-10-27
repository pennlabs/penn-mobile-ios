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
    
    fileprivate func getDummyUsers() -> [GSRGroupMember] {
        let daniel = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Daniel", last: "Salib", email: "dsalib@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let rehaan = GSRGroupMember(accountID: "1", pennKey: "rehaan", first: "Rehaan", last: "Furniturewala", email: "rehaan@wharton.upenn.edu", isBookingEnabled: false, isAdmin: false)
        let lucy = GSRGroupMember(accountID: "1", pennKey: "dsalib", first: "Lucy", last: "Yuan", email: "yuewei@seas.upenn.edu", isBookingEnabled: false, isAdmin: false)
        return [daniel, rehaan, lucy]
    }

    func getGroups(callback: ([GSRGroup]) -> ()) {
        let users = getDummyUsers()
        let labs = GSRGroup(id: "1", name: "Penn Labs", imgURL: nil, color: "blue", owners: [users[0]], members: users, createdAt: Date(), isActive: true, reservations: ["reservation1", "reservation2"])
        let cis121 = GSRGroup(id: "2", name: "CIS 121 Study Group", imgURL: nil, color: "green", owners: users, members: users, createdAt: Date(), isActive: true, reservations: [])
        let cis160 = GSRGroup(id: "3", name: "CIS 160 Study Group", imgURL: nil, color: "red", owners: [users[1]], members: users, createdAt: Date(), isActive: true, reservations: [])
        
        callback([labs, cis121, cis160])
    }
}
