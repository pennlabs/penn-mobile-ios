//
//  UserDBManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/20/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserDBManager: NSObject {
    static let shared = UserDBManager()
    fileprivate let baseUrl = "https://api.pennlabs.org"
    
    fileprivate func getAnalyticsRequest(url: String) -> NSMutableURLRequest {
        let url = URL(string: url)!
        let request = NSMutableURLRequest(url: url)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        print(deviceID)
        request.setValue("test", forHTTPHeaderField: "X-Device-ID")
        return request
    }
    
    fileprivate func getPostString(params: [String: Any]) -> String {
        var data = [String]()
        for(key, value) in params {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
}

// MARK: - Dining
extension UserDBManager {
    func saveDiningPreference(for venue: DiningVenue) {
        let urlString = "\(baseUrl)/dining/preferences"
        let id = venue.venue.getID()
        let params = ["venue_id": id]
        let request = getAnalyticsRequest(url: urlString)
        request.httpMethod = "POST"
        request.httpBody = getPostString(params: params).data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
    }
}

// MARK: - Laundry
extension UserDBManager {
    func saveLaundryPreferences(for rooms: [LaundryRoom]) {
        let urlString = "\(baseUrl)/laundry/preferences"
        let ids = rooms.map { $0.id }
        let params = ["rooms": ids]
        let request = getAnalyticsRequest(url: urlString)
        request.httpMethod = "POST"
        request.httpBody = getPostString(params: params).data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
    }
}
