//
//  CourseAlertNetworkManager.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//
import Foundation
import SwiftyJSON
import PennMobileShared
import LabsPlatformSwift

struct Response: Decodable {
    let message: String
}

enum RequestType {
    case POST
    case PATCH
    case PUT
}

class CourseAlertNetworkManager: NSObject, Requestable {

    static let instance = CourseAlertNetworkManager()

    let settingsURL = "https://penncoursealert.com/accounts/me/"
    let coursesURL = "https://penncoursealert.com/api/base/"
    let registrationsURL = "https://penncoursealert.com/api/alert/registrations/"
    let pathRegistrationURL = "https://penncourseplan.com/api/plan/schedules/path/"

    func getSearchedCourses(searchText: String, _ callback: @escaping (_ results: [CourseSection]?) -> Void) {

        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let semester: String

        if month < 5 {
            semester = "A"
        } else if month < 9 {
            semester = "B"
        } else {
            semester = "C"
        }

        let urlStr = "\(coursesURL)\(year)\(semester)/search/sections/?search=\(searchText)"
        let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                if let sectionsData = try? JSON(data).rawData() {
                    let results = try? JSONDecoder().decode([CourseSection].self, from: sectionsData)
                    callback(results)
                    return
                }
            }
            callback(nil)
        }
        task.resume()
    }

    func getRegistrations(callback: @escaping (_ registrations: [CourseAlert]?) -> Void) {
        makeGetRequestWithAccessToken(url: registrationsURL) { (data, _, error) in
            guard let data = data, error == nil  else {
                callback(nil)
                return
            }

            guard let registrations = try? JSONDecoder().decode([CourseAlert].self, from: data) else {
                callback(nil)
                return
            }

            callback(registrations)
        }
    }

    func getSettings(callback: @escaping (_ settings: CourseAlertSettings?) -> Void) {
        makeGetRequestWithAccessToken(url: settingsURL) { (data, _, error) in
            guard let data = data, error == nil  else {
                callback(nil)
                return
            }

            guard let settings = try? JSONDecoder().decode(CourseAlertSettings.self, from: data) else {
                callback(nil)
                return
            }

            UserDefaults.standard.set(.pennCourseAlerts, to: settings.profile.pushNotifications)

            callback(settings)
        }
    }

    func updatePushNotifSettings(pushNotif: Bool, callback: @escaping (_ success: Bool, _ message: String, _ error: Error?) -> Void) {
        let params: [String: Any] = ["profile": ["push_notifications": pushNotif]]
        makeAuthenticatedRequest(url: settingsURL, requestType: RequestType.PATCH, params: params) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, "", error)
                return
            }

            guard data != nil else {
                callback(false, "", error)
                return
            }

            callback((200..<300).contains(status.statusCode), "DONE", error)
        }
    }

    func createRegistration(section: String, autoResubscribe: Bool, callback: @escaping (_ success: Bool, _ response: String, _ error: Error?) -> Void) {
        let params: [String: Any] = ["section": section, "auto_resubscribe": autoResubscribe]
        makeAuthenticatedRequest(url: registrationsURL, requestType: RequestType.POST, params: params) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, "", error)
                return
            }

            guard let data = data else {
                callback(false, "", error)
                return
            }

            guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
                callback(false, "", error)
                return
            }

            callback(status.statusCode == 201, response.message, error)
        }
    }

    func updateRegistration(id: String, deleted: Bool?, autoResubscribe: Bool?, cancelled: Bool?, resubscribe: Bool?, callback: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        var params: [String: Any] = [:]
        if let deleted = deleted {
            params.updateValue(deleted, forKey: "deleted")
        }
        if let autoResubscribe = autoResubscribe {
            params.updateValue(autoResubscribe, forKey: "auto_resubscribe")
        }
        if let cancelled = cancelled {
            params.updateValue(cancelled, forKey: "cancelled")
        }
        if let resubscribe = resubscribe {
            params.updateValue(resubscribe, forKey: "resubscribe")
        }

        makeAuthenticatedRequest(url: "\(registrationsURL)\(id)/", requestType: RequestType.PUT, params: params) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, error)
                return
            }

            guard data != nil else {
                callback(false, error)
                return
            }

            callback((200..<300).contains(status.statusCode), error)
        }
    }

    func updatePathRegistration(srcdb: String, crns: [String]) async throws {
        let params: [String: Any] = ["semester": srcdb, "sections": crns.map { ["id": $0] }]

        return try await withCheckedThrowingContinuation { continuation in
            makeAuthenticatedRequest(url: pathRegistrationURL, requestType: RequestType.PUT, params: params) { (data, response, error) in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                    continuation.resume(throwing: NetworkingError.serverError)
                    return
                }
                
                continuation.resume(returning: ())
            }
        }
    }

}

// MARK: - General Networking Functions
extension CourseAlertNetworkManager {
    fileprivate func makeGetRequestWithAccessToken(url: String, callback: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) {
        Task {
            let url = URL(string: url)!
            guard let request = try? await URLRequest(url: url, mode: .accessToken) else {
                callback(nil, nil, nil)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
            task.resume()
        }
    }

    fileprivate func makeAuthenticatedRequest(url: String, requestType: RequestType, params: [String: Any]?, callback: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.getCSRFTokenCookie { (csrfToken) in
            Task {
                let url = URL(string: url)!
                guard var request = try? await URLRequest(url: url, mode: .accessToken),
                let csrfToken else {
                    callback(nil, nil, nil)
                    return
                }

                let jar = HTTPCookieStorage.shared
                let cookieHeaderField = ["Set-Cookie": "csrftoken=\(csrfToken)"]
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
                jar.setCookies(cookies, for: url, mainDocumentURL: url)

                

                switch requestType {
                case .POST:
                    request.httpMethod = "POST"
                case .PATCH:
                    request.httpMethod = "PATCH"
                case .PUT:
                    request.httpMethod = "PUT"
                }

                if let params = params,
                    let httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    request.addValue("\(csrfToken)", forHTTPHeaderField: "X-CSRFToken")
                    request.addValue("https://penncoursealert.com/api/", forHTTPHeaderField: "Referer")
                    request.httpBody = httpBody
                }

                let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
                task.resume()
            }
        }
    }

    fileprivate func getCSRFTokenCookie(_ callback: @escaping (_ csrfToken: String?) -> Void) {
        if let CSRFDict = (UserDefaults.standard.dictionary(forKey: "cookies"))?["csrftokenplatform.pennlabs.org"] as? [String: Any] {
            if let csrfToken = CSRFDict["Value"] as? String {
                callback(csrfToken)
                return
            }
        }
        
        callback(nil)
    }

}
