//
//  UserDBManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/20/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import SwiftyJSON
import PennMobileShared
import WidgetKit
import LabsPlatformSwift

class UserDBManager: NSObject, Requestable, SHA256Hashable {
    static let shared = UserDBManager()
    fileprivate let baseUrl = "https://api.pennlabs.org"

    /**
      Retrieves an access token and makes an authenticated POST request by adding it as a header to the request.
      Note: Do NOT use this to make POST requests to non-Labs services. Doing so will compromise the user's access token.
     
      - parameter url: A string URL.
      - parameter params: A dictionary of parameters to attach to the POST request.
      - parameter callback: A callback containing the data and  response that the request receives.
    */
    fileprivate func makePostRequestWithAccessToken(url: String, params: [String: Any], callback: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) {
        Task {
            do {
                guard let url = URL(string: url) else {
                    callback(nil, nil, nil)
                    return
                }
                
                var request = try await URLRequest(url: url, mode: .accessToken)
                request.httpMethod = "POST"
                request.httpBody = String.getPostString(params: params).data(using: .utf8)

                let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
                task.resume()
            } catch {
                callback(nil, nil, error)
                return
            }
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
        guard let pennkey = KeychainAccessible.instance.getPennKey(), let password = KeychainAccessible.instance.getPassword(), let privateUUID = privacyOption.privateUUID else {
            return request
        }
        let passwordHash = hash(string: pennkey + "-" + password + "-" + privacyOption.rawValue, encoding: .hex)
        request.setValue(passwordHash, forHTTPHeaderField: "X-Password-Hash")
        request.setValue(privateUUID, forHTTPHeaderField: "X-Device-Key")
        request.setValue(privacyOption.rawValue, forHTTPHeaderField: "X-Data-Type")
        return request
    }
}

// MARK: - Dining
extension UserDBManager {
    func fetchDiningPreferences() async -> Result<[DiningVenue], any Error> {
        do {
            let url = URL(string: "https://pennmobile.org/api/dining/preferences/")!
            let request = try await URLRequest(url: url, mode: .accessToken)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return .failure(NetworkingError.serverError)
            }
            let diningVenueIds = JSON(data)["preferences"].arrayValue.map({ $0["venue_id"].int! })
            let diningVenues = DiningAPI.instance.getVenues(with: diningVenueIds)
            return .success(diningVenues)
        } catch {
            return .failure(error)
        }
    }
        

    func saveDiningPreference(for venueIds: [Int]) {
        NotificationCenter.default.post(name: NSNotification.Name("favoritesUpdated"), object: nil)
        let url = URL(string: "https://pennmobile.org/api/dining/preferences/")!
        Task {
            var request = (try? await URLRequest(url: url, mode: .accessToken)) ?? URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSON(["venues": venueIds]).rawData()
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // Cache a user's favorite dining halls for use by dining hours widget.
            let diningVenues = DiningAPI.instance.getVenues(with: venueIds)
            Storage.store(diningVenues, to: .groupCaches, as: DiningAPI.favoritesCacheFileName)
            WidgetKind.diningHoursWidgets.forEach {
                WidgetCenter.shared.reloadTimelines(ofKind: $0)
            }

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
        let url = URL(string: "https://pennmobile.org/api/laundry/preferences/")!
        let params = ["rooms": ids]
        Task {
            var request = (try? await URLRequest(url: url, mode: .accessToken)) ?? URLRequest(url: url)
            request.httpMethod = "POST"

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSON(params).rawData()

            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }

    func getLaundryPreferences(_ callback: @escaping (_ rooms: [Int]?) -> Void) {
        let url = URL(string: "https://pennmobile.org/api/laundry/preferences/")!
        Task {
            var request = (try? await URLRequest(url: url, mode: .accessToken)) ?? URLRequest(url: url)

            let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
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

            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, _) in
                var accountID: String?
                if let httpResponse = response as? HTTPURLResponse {
                    if (200..<300).contains(httpResponse.statusCode) {
                        if let data = data, NSString(data: data, encoding: String.Encoding.utf8.rawValue) != nil {
                            let json = JSON(data)
                            accountID = json["account_id"].string
                        }
                    }
                }
                completion(accountID)
            })
            task.resume()
        } catch {
            completion(nil)
        }
    }

    func deleteAnonymousCourses(_ completion: @escaping (_ success: Bool) -> Void) {
        var request = getAnonymousPrivacyRequest(url: "\(baseUrl)/account/courses/private/delete", for: .anonymizedCourseSchedule)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (_, response, _) in
            if let httpResponse = response as? HTTPURLResponse {
                completion((200..<300).contains(httpResponse.statusCode))
            } else {
                completion(false)
            }
        })
        task.resume()
    }

    func getWhartonStatus(_ completion: @escaping (_ result: Result<Bool, NetworkingError>) -> Void) {
        let url = URL(string: "https://pennmobile.org/api/gsr/wharton/")!
        Task { @MainActor in
            guard let request = try? await URLRequest(url: url, mode: .accessToken) else {
                completion(.failure(.authenticationError))
                return
            }
            
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError))
                return
            }
            
            if let isWharton = try? JSON(data: data)["is_wharton"].bool {
                completion(.success(isWharton))
            } else {
                completion(.failure(.serverError))
            }
        }
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
            if let data = data, let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
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
        
        let url = URL(string: "\(self.baseUrl)/housing/all")!
        Task {
            guard var request = try? await URLRequest(url: url, mode: .accessToken) else {
                completion?(false)
                return
            }
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try? jsonEncoder.encode(housingResults)
            request.httpBody = jsonData
            
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion?(false)
                return
            }
            
            completion?(true)
        }
    }

    func deleteHousingData(_ completion: (( _ success: Bool) -> Void)? = nil) {
        let url = "\(baseUrl)/housing/delete"
        makePostRequestWithAccessToken(url: url, params: [:]) { (_, response, _) in
            if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
}

// MARK: - Privacy and Notification Settings
extension UserDBManager {
    func fetchNotificationSettings(_ completion: @escaping (_ result: Result<[NotificationSetting], NetworkingError>) -> Void) {
        let url = URL(string: "https://pennmobile.org/api/user/notifications/settings/")!
        Task {
            guard let request = try? await URLRequest(url: url, mode: .accessToken) else {
                completion(.failure(.authenticationError))
                return
            }
            
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError))
                return
            }
            
            let decoder = JSONDecoder()
            if let notifSettings = try? decoder.decode([NotificationSetting].self, from: data) {
                completion(.success(notifSettings))
            } else {
                completion(.failure(.parsingError))
            }
        }
    }

    func updateNotificationSetting(id: Int, service: String, enabled: Bool, _ callback: ((_ success: Bool) -> Void)?) {
        let url = URL(string: "https://pennmobile.org/api/user/notifications/settings/\(id)/")!
        Task {
            guard var request = try? await URLRequest(url: url, mode: .accessToken),
                  let payload = try? JSONSerialization.data(withJSONObject: ["service": service, "enabled": enabled]) else {
                callback?(false)
                return
            }
            
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = payload
            
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) || httpResponse.statusCode == 201 else {
                callback?(false)
                return
            }
            
            callback?(true)
        }
    }

    // TO-DO: Remove/update below functions with api/user/privacy/settings/ route
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

        let url = URL(string: "\(baseUrl)/account/settings")!

        struct CodableUserSettings: Codable {
            let notifications: NotificationPreferences
            let privacy: PrivacyPreferences
        }
        
        Task {
            guard var request = try? await URLRequest(url: url, mode: .accessToken),
                let (data, response) = try? await URLSession.shared.data(for: request),
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode),
                let settings = try? JSONDecoder().decode(CodableUserSettings.self, from: data) else {
                    callback(false, nil, nil)
                    return
            }
            callback(true, settings.privacy, settings.notifications)
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

    private func saveUserSettingsDictionary(route: String, params: [String: Bool], _ callback: ((_ success: Bool) -> Void)?) {
        let url = URL(string: route)!
        Task {
            guard var request = try? await URLRequest(url: url, mode: .accessToken),
                  let payload = try? JSONEncoder().encode(params) else {
                callback?(false)
                return
            }
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = payload
            
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                callback?(false)
                return
            }
            
            callback?(true)
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
            if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }

    func saveAcademicInfo(_ degrees: Set<Degree>, _ completion: (( _ success: Bool) -> Void)? = nil) {
        let url = URL(string: "\(self.baseUrl)/account/degrees")!
        
        Task {
            guard var request = try? await URLRequest(url: url, mode: .accessToken) else {
                completion?(false)
                return
            }
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try? jsonEncoder.encode(degrees)
            request.httpBody = jsonData
            
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion?(false)
                return
            }
            
            completion?(true)
        }
    }
}

// MARK: - Fitness
extension UserDBManager {
    
    func saveFitnessPreferences(for rooms: [FitnessRoom]) {
        let ids = rooms.map { $0.id }
        saveFitnessPreferences(for: ids)
    }

    func saveFitnessPreferences(for ids: [Int]) {
        let url = URL(string: "https://pennmobile.org/api/fitness/preferences/")!
        let params = ["rooms": ids]
        
        Task {
            guard var request = try? await URLRequest(url: url, mode: .accessToken) else {
                return
            }
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSON(params).rawData()
            
            let _ = try? await URLSession.shared.data(for: request)
        }


    }

    func getFitnessPreferences(_ callback: @escaping (_ rooms: [Int]?) -> Void) {
        let url = URL(string: "https://pennmobile.org/api/fitness/preferences/")!
        Task {
            guard var request = try? await URLRequest(url: url, mode: .accessToken) else {
                callback(nil)
                return
            }
            
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                callback(nil)
                return
            }
            
            if let rooms = JSON(data)["rooms"].arrayObject {
                callback(rooms.compactMap { $0 as? Int })
                return
            }
            callback(nil)
        }
    }
}
