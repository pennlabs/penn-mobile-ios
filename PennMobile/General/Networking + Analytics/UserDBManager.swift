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
    fileprivate let baseUrl = "http://localhost:5000"//"https://api.pennlabs.org"
    
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
    func saveDiningPreference(for venues: [DiningVenue]) {
        let urlString = "\(baseUrl)/dining/preferences"
        let ids = venues.map { $0.getID() }.filter { $0 != nil}.map { $0! }
        let params = ["venues": ids]
        let request = getAnalyticsPostRequest(url: urlString, params: params)
        sendRequest(request)
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

// MARK: - Student Account
extension UserDBManager {
    func saveStudent(_ student: Student, _ completion: @escaping (_ accountID: String?) -> Void) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let url = URL(string: "\(baseUrl)/account/register")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try jsonEncoder.encode(student)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                var accountID: String? = nil
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            let json = JSON(data)
                            accountID = json["account_id"].string
                        }
                    } else {
                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            let json = JSON(data)
                            let error = json["error"].stringValue
                            print(error)
                        }
                    }
                }
                completion(accountID)
            })
            task.resume()
        }
        catch {
            completion(nil)
        }
    }
    
    func saveCourses(_ courses: Set<Course>, accountID: String, _ completion: @escaping (_ success: Bool) -> Void) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let url = URL(string: "\(baseUrl)/account/courses")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let coursesObj = CoursesJSON(accountID: accountID, courses: courses)
            let jsonData = try jsonEncoder.encode(coursesObj)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                var success = false
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            let json = JSON(data)
                            success = json["success"].boolValue
                        }
                    } else {
                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            let json = JSON(data)
                            let error = json["error"].stringValue
                            print(error)
                        }
                    }
                }
                completion(success)
            })
            task.resume()
        }
        catch {
            completion(false)
        }
    }
}
