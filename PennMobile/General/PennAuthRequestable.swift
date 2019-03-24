//
//  PennNetworking.swift
//  PennMobile
//
//  Created by Josh Doman on 3/23/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol PennAuthRequestable {}

extension PennAuthRequestable {
    
    private var loginUrl: String {
        return "https://weblogin.pennkey.upenn.edu/login"
    }
    
    private var reauthUrl: String {
        return "https://idp.pennkey.upenn.edu/idp/Authn/ReauthRemoteUser"
    }
    
    func makeAuthRequest(targetUrl: String, shibbolethUrl: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: targetUrl)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let urlStr = response?.url?.absoluteString, urlStr == targetUrl {
                completionHandler(data, response, error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue),
                let urlStr = response.url?.absoluteString {
                if urlStr == targetUrl {
                    completionHandler(data, response, error)
                } else if urlStr.contains(self.reauthUrl) {
                    self.makeRequestWithReauth(shibbolethUrl: shibbolethUrl, html: html as String, completionHandler)
                } else {
                    self.makeRequestWithShibboleth(shibbolethUrl: shibbolethUrl, html: html as String, completionHandler)
                }
            } else {
                completionHandler(nil, nil, NetworkingError.authenticationError)
            }
            UserDefaults.standard.storeCookies()
        }
        task.resume()
    }
    
    private func makeRequestWithReauth(shibbolethUrl: String, html: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let passcode = html.getMatches(for: "name=\"passcode\" value=\"(.*?)\"").first,
                let required = html.getMatches(for: "name=\"required\" value=\"(.*?)\"").first,
                let appfactor = html.getMatches(for: "name=\"appfactor\" value=\"(.*?)\"").first,
                let ref = html.getMatches(for: "name=\"ref\" value=\"(.*?)\"").first,
                let service = html.getMatches(for: "name=\"service\" value=\"(.*?)\"").first,
                let login = html.getMatches(for: "name=\"login\" value=\"(.*?)\"").first,
                let reauth = html.getMatches(for: "name=\"reauth\" value=\"(.*?)\"").first else {
                completionHandler(nil, nil, NetworkingError.authenticationError)
                return
        }
        
        let url = URL(string: loginUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let genericPwdQueryable =
            GenericPasswordQueryable(service: "PennWebLogin")
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)
        
        let password: String?
        do {
            password = try secureStore.getValue(for: "PennKey Password")
        } catch {
            password = nil
        }
        
        if password == nil {
            completionHandler(nil, nil, NetworkingError.authenticationError)
            return
        }
        
        let params: [String: String] = [
            "password": password!,
            "submit1": "Log in",
            "passcode": passcode,
            "required": required,
            "appfactor": appfactor,
            "ref": ref,
            "service": service,
            "login": login,
            "reauth": reauth,
        ]
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let parameterArray = params.map { key, value -> String in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
            let escapedValue: String = value.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }
        let encodedParams = parameterArray.joined(separator: "&")
        request.httpBody = encodedParams.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                self.makeRequestWithShibboleth(shibbolethUrl: shibbolethUrl, html: html as String, completionHandler)
            } else {
                completionHandler(nil, nil, NetworkingError.authenticationError)
            }
            UserDefaults.standard.storeCookies()
        }
        task.resume()
    }
    
    private func makeRequestWithShibboleth(shibbolethUrl: String, html: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let samlResponse = html.getMatches(for: "<input type=\"hidden\" name=\"SAMLResponse\" value=\"(.*?)\"/>").first,
            let relayState = html.getMatches(for: "<input type=\"hidden\" name=\"RelayState\" value=\"(.*?)\"/>").first?.replacingOccurrences(of: "&#x3a;", with: ":") else {
                completionHandler(nil, nil, NetworkingError.authenticationError)
                return
        }
        
        let url = URL(string: shibbolethUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "RelayState": String(relayState),
            "SAMLResponse": samlResponse
        ]
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let parameterArray = params.map { key, value -> String in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
            let escapedValue: String = value.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }
        let encodedParams = parameterArray.joined(separator: "&")
        request.httpBody = encodedParams.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        
        UserDefaults.standard.storeCookies()
    }
}
