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
    
    fileprivate func getAnalyticsRequest(for url: String) -> NSMutableURLRequest {
        let url = URL(string: url)!
        let request = NSMutableURLRequest(url: url)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
        return request
    }
}

// MARK: - Dining
extension UserDBManager {
    func savePreference(for venue: DiningVenue) {
        let urlString = "\(baseUrl)/dining/preferences"
        let request = getAnalyticsRequest(for: urlString)
        let params = [
            "venue_id": 0
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
    }
}

// MARK: - Laundry
extension UserDBManager {
    func savePreferences(for rooms: [LaundryRoom]) {
        let urlString = "\(baseUrl)/laundry/preferences"
        let request = getAnalyticsRequest(for: urlString)
        let ids = rooms.map { $0.id }
        let params = [
            "rooms": ids
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
    }
}
