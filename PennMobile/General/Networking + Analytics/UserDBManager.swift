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
    #if DEBUG
       return "test"
    #else
        return deviceID
    #endif
}

class UserDBManager: NSObject, Requestable, KeychainAccessible, SHA256Hashable {
    static let shared = UserDBManager()
    fileprivate let baseUrl = "https://api.pennlabs.org"
    
    /**
      Retrieves an access token and makes an authenticated POST request by adding it as a header to the request.
      Note: Do NOT use this to make POST requests to non-Labs services. Doing so will compromise the user's access token.
     
      - parameter url: A string URL.
      - parameter params: A dictionary of parameters to attach to the POST request.
      - parameter callback: A callback containing the data and  response that the request receives.
    */
    fileprivate func makePostRequestWithAccessToken(url: String, params: [String: Any], callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            let url = URL(string: url)!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "POST"
            request.httpBody = String.getPostString(params: params).data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
            task.resume()
        }
    }
    
    /**
      Returns a URLRequest configured for making anonymous requests. The server matches either the pennkey-password hash or the private UUID in the DB to find the anonymous account ID, updating the identifiers if the password of device changes.
     
      - parameter url: A string URL.
      - parameter privacyOption: A PrivacyOption
     
      - returns: URLRequest containing the data type, a SHA256 hash of the pennkey-password, and the privacy option UUID in the headers
    */
    fileprivate func getAnonymousPrivacyRequest(url: String, for privacyOption: PrivacyOption) -> URLRequest {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        guard let pennkey = getPennKey(), let password = getPassword(), let privateUUID = privacyOption.privateUUID else {
            return request
        }
        let passwordHash = hash(string: pennkey + "-" + password)
        request.setValue(passwordHash, forHTTPHeaderField: "X-Password-Hash")
        request.setValue(privateUUID, forHTTPHeaderField: "X-Device-Key")
        request.setValue(privacyOption.rawValue, forHTTPHeaderField: "X-Data-Type")
        return request
    }
}

// MARK: - Dining
extension UserDBManager {
    func saveDiningPreference(for venueIds: [Int]) {
        let url = "\(baseUrl)/dining/preferences"
        let params = ["venues": venueIds]

        OAuth2NetworkManager.instance.getAccessToken { (token) in
            let url = URL(string: url)!
            var request = token != nil ? URLRequest(url: url, accessToken: token!) : URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = String.getPostString(params: params).data(using: .utf8)
            
            let deviceID = getDeviceID()
            request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")

            let task = URLSession.shared.dataTask(with: request)
            task.resume()
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
        let url = "\(baseUrl)/laundry/preferences"
        let params = ["rooms": ids]

        OAuth2NetworkManager.instance.getAccessToken { (token) in
            let url = URL(string: url)!
            var request = token != nil ? URLRequest(url: url, accessToken: token!) : URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = String.getPostString(params: params).data(using: .utf8)
            
            let deviceID = getDeviceID()
            request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")

            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }
    
    func getLaundryPreferences(_ callback: @escaping (_ rooms: [Int]?) -> Void) {
        let url = "\(baseUrl)/laundry/preferences"
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            let url = URL(string: url)!
            var request = token != nil ? URLRequest(url: url, accessToken: token!) : URLRequest(url: url)
            
            let deviceID = getDeviceID()
            request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data, let rooms = JSON(data)["rooms"].arrayObject {
                    callback(rooms.compactMap { $0 as? Int })
                    return
                }
                callback(nil)
            }
            task.resume()
        }
    }
}

// MARK: - Dining Balance
extension UserDBManager {
    func parseAndSaveDiningBalanceHTML(html: String, _ completion: @escaping (_ hasDiningPlan: Bool?, _ balance: DiningBalance?) -> Void) {
        let url = "\(baseUrl)/dining/balance"
        let params = ["html": html]
        makePostRequestWithAccessToken(url: url, params: params) { (data, response, error) in
            if let data = data {
                let json = JSON(data)
                if let hasPlan = json["hasPlan"].bool {
                    var balance: DiningBalance? = nil
                    if let dollars = json["balance"]["dollars"].float,
                        let swipes = json["balance"]["swipes"].int,
                        let guestSwipes = json["balance"]["guest_swipes"].int {
                        balance = DiningBalance(diningDollars: dollars, visits: swipes, guestVisits: guestSwipes, lastUpdated: Date())
                    }
                    completion(hasPlan, balance)
                    return
                }
            }
            completion(nil, nil)
        }
    }
}

// MARK: - Student Account
extension UserDBManager {
    func saveAccount(_ account: Account, _ completion: @escaping (_ accountID: String?) -> Void) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let url = URL(string: "\(baseUrl)/account/register")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try jsonEncoder.encode(account)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                var accountID: String? = nil
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            let json = JSON(data)
                            accountID = json["account_id"].string
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
    
    func saveCourses(_ courses: Set<Course>, accountID: String, _ completion: ((_ success: Bool) -> Void)? = nil) {
        completion?(true)
//        let jsonEncoder = JSONEncoder()
//        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
//        do {
//            let url = URL(string: "\(baseUrl)/account/courses")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let coursesObj = CoursesJSON(accountID: accountID, courses: courses)
//            let jsonData = try jsonEncoder.encode(coursesObj)
//            request.httpBody = jsonData
//
//            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//                var success = false
//                if let httpResponse = response as? HTTPURLResponse {
//                    if httpResponse.statusCode == 200 {
//                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
//                            let json = JSON(data)
//                            success = json["success"].boolValue
//                        }
//                    } else {
//                        if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
//                            let json = JSON(data)
//                            let error = json["error"].stringValue
//                            print(error)
//                        }
//                    }
//                }
//                completion?(success)
//            })
//            task.resume()
//        }
//        catch {
//            completion?(false)
//        }
    }
    
    func saveCoursesAnonymously(_ courses: Set<Course>, _ completion: ((_ success: Bool) -> Void)? = nil) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            var request = getAnonymousPrivacyRequest(url: "\(baseUrl)/account/courses/private/save", for: .anonymizedCourseSchedule)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let jsonData = try jsonEncoder.encode(courses)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        UserDefaults.standard.setLastShareDate(for: .anonymizedCourseSchedule)
                    }
                    completion?(httpResponse.statusCode == 200)
                } else {
                    completion?(false)
                }
            })
            task.resume()
        }
        catch {
            completion?(false)
        }
    }
    
    func deleteAnonymousCourses(_ completion: @escaping (_ success: Bool) -> Void) {
        var request = getAnonymousPrivacyRequest(url: "\(baseUrl)/account/courses/private/delete", for: .anonymizedCourseSchedule)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        })
        task.resume()
    }
}

// MARK: - Transaction Data
extension UserDBManager {
    func saveTransactionData(csvStr: String, _ callback: (() -> Void)? = nil) {
        let url = "\(baseUrl)/dining/transactions"
        let params = ["transactions": csvStr]
        makePostRequestWithAccessToken(url: url, params: params) { (_, _, _) in
            callback?()
        }
    }
}

// MARK: - Housing Data
extension UserDBManager {
    /// Uploads raw CampusExpress housing html to the server, which parses it and saves the corresponding housing result. This result is returned and stored in UserDefaults.
    func saveHousingData(html: String, _ completion: (( _ result: HousingResult?) -> Void)? = nil) {
        let url = "\(baseUrl)/housing"
        let params = ["html": html]
        makePostRequestWithAccessToken(url: url, params: params) { (data, response, _) in
            if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let result = try? decoder.decode(HousingResult.self, from: data) {
                    UserDefaults.standard.saveHousingResult(result)
                    completion?(result)
                    return
                }
            }
            completion?(nil)
        }
    }
    
    /// Uploads all housing results stored in UserDefaults to the server
    func saveMultiyearHousingData(_ completion: (( _ success: Bool) -> Void)? = nil) {
        guard let housingResults = UserDefaults.standard.getHousingResults() else {
            completion?(true)
            return
        }
        
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                completion?(false)
                return
            }
            
            let url = URL(string: "\(self.baseUrl)/housing/all")!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try? jsonEncoder.encode(housingResults)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { (data, response, _) in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
            task.resume()
        }
    }
    
    func deleteHousingData(_ completion: (( _ success: Bool) -> Void)? = nil) {
        let url = "\(baseUrl)/housing/delete"
        makePostRequestWithAccessToken(url: url, params: [:]) { (_, response, _) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
}

// MARK: - Privacy and Notification Settings
extension UserDBManager {
    func syncUserSettings(_ callback: @escaping (_ success: Bool) -> Void) {
        self.fetchUserSettings { (success, privacySettings, notificationSettings) in
            if success {
                if let privacySettings = privacySettings {
                    UserDefaults.standard.saveAll(privacyPreferences: privacySettings)
                }
                if let notificationSettings = notificationSettings {
                    UserDefaults.standard.saveAll(notificationPreferences: notificationSettings)
                }
            }
            callback(success)
        }
    }
    
    func fetchUserSettings(_ callback: @escaping (_ success: Bool, _ privacyPreferences: PrivacyPreferences?, _ notificationPreferences: NotificationPreferences?) -> Void) {
        
        let urlRoute = "\(baseUrl)/account/settings"
        
        struct CodableUserSettings: Codable {
            let notifications: NotificationPreferences
            let privacy: PrivacyPreferences
        }
        
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            if let token = token {
                let url = URL(string: urlRoute)!
                let request = URLRequest(url: url, accessToken: token)
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if error == nil, let data = data, let settings = try? JSONDecoder().decode(CodableUserSettings.self, from: data) {
                        callback(true, settings.privacy, settings.notifications)
                    } else {
                        callback(false, nil, nil)
                    }
                }
                task.resume()
            } else {
                callback(false, nil, nil)
            }
        }
    }
    
    func saveUserNotificationSettings(_ callback: ((_ success: Bool) -> Void)? = nil) {
        let urlRoute = "\(baseUrl)/notifications/settings"
        let params = UserDefaults.standard.getAllNotificationPreferences()
        saveUserSettingsDictionary(route: urlRoute, params: params, callback)
    }
    
    func saveUserPrivacySettings(_ callback: ((_ success: Bool) -> Void)? = nil) {
        let urlRoute = "\(baseUrl)/privacy/settings"
        let params = UserDefaults.standard.getAllPrivacyPreferences()
        saveUserSettingsDictionary(route: urlRoute, params: params, callback)
    }
    
    private func saveUserSettingsDictionary(route: String, params: Dictionary<String, Bool>, _ callback: ((_ success: Bool) -> Void)?) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token, let payload = try? JSONEncoder().encode(params) else {
                callback?(false)
                return
            }
            
            let url = URL(string: route)!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = payload
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    callback?(httpResponse.statusCode == 200)
                } else {
                    callback?(false)
                }
            }
            task.resume()
        }
    }
}

// MARK: - Push Notifications
extension UserDBManager {
    func savePushNotificationDeviceToken(deviceToken: String, _ completion: (() -> Void)? = nil) {
        let url = "\(baseUrl)/notifications/register"
        var params: [String: Any] = ["ios_token": deviceToken]
        #if DEBUG
            params["dev"] = true
        #endif
        makePostRequestWithAccessToken(url: url, params: params) { (_, _, _) in
            completion?()
        }
    }
    
    func clearPushNotificationDeviceToken(_ completion: (() -> Void)? = nil) {
        let url = "\(baseUrl)/notifications/register"
        makePostRequestWithAccessToken(url: url, params: [:]) { (_, _, _) in
            completion?()
        }
    }
}

// MARK: - Anonymized Courses
extension UserDBManager {
    func saveCourses(_ courses: Set<Course>, _ callback: @escaping (_ success: Bool) -> Void) {
        guard UserDefaults.standard.getPreference(for: .anonymizedCourseSchedule) else {
            // We don't have permission! Do not upload anon courses.
            callback(false)
            return
        }
        let route = "\(baseUrl)/account/courses"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        // TODO: Make this uuid string saved somewhere.
        let codableCourses = CoursesJSON(id: UUID().uuidString, courses: courses)
        
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token, let payload = try? encoder.encode(codableCourses) else {
                callback(false)
                return
            }
            
            let url = URL(string: route)!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = payload
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    callback(httpResponse.statusCode == 200)
                } else {
                    callback(false)
                }
            }
            task.resume()
        }
    }
}

// MARK: - Anonymized Token Registration
extension UserDBManager {
    /// Updates the anonymization keys in case either of them changed. The only key that may change is the pennkey-password.
    func updateAnonymizationKeys() {
        for option in PrivacyOption.anonymizedOptions {
            var request = getAnonymousPrivacyRequest(url: "\(baseUrl)/privacy/anonymous/register", for: option)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }
}

// MARK: - Academic Degrees
extension UserDBManager {
    /// Deletes all academic degree information from server (school, grad year, major)
    func deleteAcademicInfo(_ completion: (( _ success: Bool) -> Void)? = nil) {
        let url = "\(baseUrl)/account/degrees/delete"
        makePostRequestWithAccessToken(url: url, params: [:]) { (_, response, _) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func saveAcademicInfo(_ degrees: Set<Degree>, _ completion: (( _ success: Bool) -> Void)? = nil) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                completion?(false)
                return
            }
            
            let url = URL(string: "\(self.baseUrl)/account/degrees")!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try? jsonEncoder.encode(degrees)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { (data, response, _) in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
            task.resume()
        }
    }
}
