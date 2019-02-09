//
//  UserDBManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/20/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

func getDeviceID() -> String {
    let deviceID = UIDevice.current.identifierForVendor!.uuidString
    return UserDBManager.shared.testRun ? "test" : deviceID
}

class UserDBManager: NSObject {
    static let shared = UserDBManager()
    fileprivate let baseUrl = "http://api-dev.pennlabs.org"
    
    var dryRun: Bool = true
    var testRun: Bool = false
    
    fileprivate func getAnalyticsRequest(url: String) -> NSMutableURLRequest {
        let url = URL(string: url)!
        let request = NSMutableURLRequest(url: url)
        let deviceID = getDeviceID()
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
        return request
    }
    
    fileprivate func getAnalyticsPostRequest(url: String, params: [String: Any]?) -> NSMutableURLRequest {
        let request = getAnalyticsRequest(url: url)
        request.httpMethod = "POST"
        if let params = params {
            request.httpBody = getPostString(params: params).data(using: .utf8)
        }
        return request
    }
    
    fileprivate func getPostString(params: [String: Any]) -> String {
        var data = [String]()
        for(key, value) in params {
            if let arr = value as? Array<Any> {
                let str = arr.map { String(describing: $0) }.joined(separator: ",")
                data.append(key + "=\(str)")
            }
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    fileprivate func sendRequest(_ request: NSMutableURLRequest) {
        if dryRun && !testRun { return }
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
    }
    
    fileprivate func sendRequest(_ request: NSMutableURLRequest, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if dryRun && !testRun { return }
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: callback)
        task.resume()
    }
}

// MARK: - Dining
extension UserDBManager {
    func saveDiningPreference(for venue: DiningVenue) {
        let urlString = "\(baseUrl)/dining/preferences"
        let id = venue.name.getID()
        let params = ["venue_id": id]
        let request = getAnalyticsPostRequest(url: urlString, params: params)
        sendRequest(request)
    }
    
    func saveDiningPreference(for venues: [DiningVenueName], callback: @escaping (Bool) -> ()) {
        let urlString = "\(baseUrl)/dining/preferences/V2"
        let ids = venues.map { $0.getID() }
        print(ids)
        let params = ["venues": ids]
        let request = getAnalyticsPostRequest(url: urlString, params: params)
        sendRequest(request) { (data, response, error) in
            callback(error == nil)
        }
    }
}

// MARK: - Laundry
extension UserDBManager {
    func saveLaundryPreferences(for rooms: [LaundryRoom]) {
        let ids = rooms.map { $0.id }
        saveLaundryPreferences(for: ids)
    }
    
    func saveLaundryPreferences(for ids: [Int]) {
        let urlString = "\(baseUrl)/laundry/preferences"
        let params = ["rooms": ids]
        let request = getAnalyticsPostRequest(url: urlString, params: params)
        sendRequest(request)
    }
}
