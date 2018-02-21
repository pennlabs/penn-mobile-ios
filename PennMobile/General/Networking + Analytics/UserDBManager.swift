//
//  UserDBManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/20/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class UserDBManager: NSObject {
    static let shared = UserDBManager()
    fileprivate let baseUrl = "https://api.pennlabs.org"
    
    fileprivate func getAnalyticsRequest(url: String, params: [String: Any]?) -> NSMutableURLRequest {
        let url = URL(string: url)!
        let request = NSMutableURLRequest(url: url)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
        if let params = params {
            request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        return request
    }
}

// MARK: - Dining
extension UserDBManager {
    func savePreference(for venue: DiningVenue) {
        let urlString = "\(baseUrl)/dining/preferences"
        let id = venue.venue.getID()
        let params = ["venue_id": id]
        let request = getAnalyticsRequest(url: urlString, params: params)
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
    }
}

// MARK: - Laundry
extension UserDBManager {
    func savePreferences(for rooms: [LaundryRoom]) {
        let urlString = "\(baseUrl)/laundry/preferences"
        let ids = rooms.map { $0.id }
        let params = ["rooms": ids]
        let request = getAnalyticsRequest(url: urlString, params: params)
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
    }
}
