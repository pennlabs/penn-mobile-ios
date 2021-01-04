//
//  CourseAlertNetworkManager.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Response: Decodable {
    let message: String
    //let id: Int
}


class CourseAlertNetworkManager: NSObject, Requestable {
    
    static let instance = CourseAlertNetworkManager()
    
    let settingsURL = "https://penncoursealert.com/api/alert/settings/"
    let coursesURL = "https://penncoursealert.com/api/alert/courses"
    let registrationsURL = "https://penncoursealert.com/api/alert/registrations/"
    
    func getSearchedCourses(searchText:String, _ callback: @escaping (_ results: [CourseSection]?) -> ()) {
        let urlStr = "\(coursesURL)/?search=\(searchText)"
        let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
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
    
    func getRegistrations(callback: @escaping ([CourseAlert]?) -> ()) {
        makeGetRequestWithAccessToken(url: registrationsURL) { (data, response, error) in
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
    
    func getSettings(callback: @escaping (CourseAlertSettings?) -> ()) {
        makeGetRequestWithAccessToken(url: settingsURL) { (data, response, error) in
            guard let data = data, error == nil  else {
                callback(nil)
                return
            }
            
            //print(String(decoding: data, as: UTF8.self))
            
            guard let settings = try? JSONDecoder().decode(CourseAlertSettings.self, from: data) else {
                callback(nil)
                return
            }

            callback(settings)
        }
    }
    
    func updatePushNotifSettings(pushNotif: Bool, callback: @escaping (Bool, String, Error?) -> ()) {
        let params: [String: Any] = ["profile": ["push_notifications":pushNotif]]
        makePatchRequestWithAccessToken(url: settingsURL, params: params) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, "", error)
                return
            }
            
            guard let data = data else {
                callback(false, "", error)
                return
            }
            
            callback(status.statusCode == 200, "DONE", error)
        }
    }
    
    func createRegistration(section: String, autoResubscribe: Bool, callback: @escaping (Bool, String, Error?) -> ()) {
        let params: [String: Any] = ["section": section, "auto_resubscribe": autoResubscribe]
        makePostRequestWithAccessToken(url: registrationsURL, params: params) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, "", error)
                return
            }
            
            guard let data = data else {
                callback(false, "", error)
                return
            }
            
            //print(String(decoding: data, as: UTF8.self))
            
            guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
                callback(false, "", error)
                return
            }
            
            callback(status.statusCode == 201, response.message, error)
        }
    }
    
    func updateRegistration(id: String, deleted: Bool?, autoResubscribe: Bool?, cancelled: Bool?, resubscribe: Bool?, callback: @escaping (Bool, Error?) -> ()) {
        var params: [String: Any] = [:]//["id": id]
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
        
        makePutRequestWithAccessToken(url: "\(registrationsURL)\(id)/", params: params) { (data, status, error) in
            guard let status = status as? HTTPURLResponse else {
                callback(false, error)
                return
            }
            
            guard let data = data else {
                callback(false, error)
                return
            }
            
            callback(status.statusCode == 200, error)
        }
    }
    
}




// MARK: - General Networking Functions
extension CourseAlertNetworkManager {
    fileprivate func makeGetRequestWithAccessToken(url: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            let url = URL(string: url)!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: callback)
            task.resume()
        }
    }
    
    fileprivate func makePostRequestWithAccessToken(url: String, params: [String: Any]?, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            self.getCSRFTokenCookie { (csrfToken) in
                
                guard let csrfToken = csrfToken else {
                    callback(nil, nil, nil)
                    return
                }
                
                let url = URL(string: url)!
                
                let jar = HTTPCookieStorage.shared
                let cookieHeaderField = ["Set-Cookie": "csrftoken=\(csrfToken)"]
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
                jar.setCookies(cookies, for: url, mainDocumentURL: url)
                
                var request = URLRequest(url: url, accessToken: token)
                request.httpMethod = "POST"
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
    
    fileprivate func makePutRequestWithAccessToken(url: String, params: [String: Any]?, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            self.getCSRFTokenCookie { (csrfToken) in
                
                guard let csrfToken = csrfToken else {
                    callback(nil, nil, nil)
                    return
                }
                
                let url = URL(string: url)!
                
                let jar = HTTPCookieStorage.shared
                let cookieHeaderField = ["Set-Cookie": "csrftoken=\(csrfToken)"]
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
                jar.setCookies(cookies, for: url, mainDocumentURL: url)
                
                var request = URLRequest(url: url, accessToken: token)
                request.httpMethod = "PUT"
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
    
    fileprivate func makePatchRequestWithAccessToken(url: String, params: [String: Any]?, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                callback(nil, nil, nil)
                return
            }
            
            self.getCSRFTokenCookie { (csrfToken) in
                
                guard let csrfToken = csrfToken else {
                    callback(nil, nil, nil)
                    return
                }
                
                let url = URL(string: url)!
                
                let jar = HTTPCookieStorage.shared
                let cookieHeaderField = ["Set-Cookie": "csrftoken=\(csrfToken)"]
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
                jar.setCookies(cookies, for: url, mainDocumentURL: url)
                
                var request = URLRequest(url: url, accessToken: token)
                request.httpMethod = "PATCH"
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
        //print(UserDefaults.standard.dictionary(forKey: "cookies"))
        if let CSRFDict = (UserDefaults.standard.dictionary(forKey: "cookies"))?["csrftokenplatform.pennlabs.org"] as? Dictionary<String, Any> {
            if let csrfToken = CSRFDict["Value"] as? String {
                //print("CSRF: \(csrfToken)")
                callback(csrfToken)
            } else {
                callback(nil)
            }
        }
        callback(nil)
    }
    
    /*
    fileprivate func getSessionIdCookie(_ callback: @escaping (_ csrfToken: String?) -> Void) {
        if let SessionDict = (UserDefaults.standard.dictionary(forKey: "cookies"))?["sessionidplatform.pennlabs.org"] as? Dictionary<String, Any> {
            if let sessionId = SessionDict["Value"] as? String {
                callback(sessionId)
            } else {
                callback(nil)
            }
        }
        callback(nil)
    }*/
    
}

