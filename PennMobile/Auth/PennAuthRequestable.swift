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
    
    private var authUrl: String {
        return "https://idp.pennkey.upenn.edu/idp/Authn"
    }
    
    func makeAuthRequest(targetUrl: String, shibbolethUrl: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: targetUrl)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let urlStr = response?.url?.absoluteString, urlStr == targetUrl {
                UserDefaults.standard.setShibbolethAuth(authedIn: true)
                completionHandler(data, response, error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue),
                let urlStr = response.url?.absoluteString {
                if urlStr == targetUrl {
                    UserDefaults.standard.setShibbolethAuth(authedIn: true)
                    completionHandler(data, response, error)
                } else if urlStr.contains(self.authUrl) {
                    self.makeRequestWithAuth(targetUrl: targetUrl, shibbolethUrl: shibbolethUrl, html: html as String, completionHandler)
                } else {
                    self.makeRequestWithShibboleth(targetUrl: targetUrl, shibbolethUrl: shibbolethUrl, html: html as String, completionHandler)
                }
            } else {
                UserDefaults.standard.setShibbolethAuth(authedIn: false)
                completionHandler(nil, nil, NetworkingError.authenticationError)
            }
            UserDefaults.standard.storeCookies()
        }
        task.resume()
    }
    
    private func makeRequestWithAuth(targetUrl: String, shibbolethUrl: String, html: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let passcode = html.getMatches(for: "name=\"passcode\" value=\"(.*?)\"").first,
                let required = html.getMatches(for: "name=\"required\" value=\"(.*?)\"").first,
                let appfactor = html.getMatches(for: "name=\"appfactor\" value=\"(.*?)\"").first,
                let ref = html.getMatches(for: "name=\"ref\" value=\"(.*?)\"").first,
                let service = html.getMatches(for: "name=\"service\" value=\"(.*?)\"").first else {
                UserDefaults.standard.setShibbolethAuth(authedIn: false)
                completionHandler(nil, nil, NetworkingError.authenticationError)
                return
        }
        
        // Check if have two factor trusted browser cookie (may have expired)
//        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let isTwoFactorTrusted = true //!cookies.filter { $0.name == "twoFactorTrustedBrowser" }.isEmpty
        
        let genericPwdQueryable =
            GenericPasswordQueryable(service: "PennWebLogin")
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)
        
        let password: String!
        do {
            password = try secureStore.getValue(for: "PennKey Password")
        } catch {
            password = nil
        }
        
        let pennkey: String!
        do {
            pennkey = try secureStore.getValue(for: "PennKey")
        } catch {
            pennkey = nil
        }
        
        guard pennkey != nil && password != nil && isTwoFactorTrusted else {
            UserDefaults.standard.setShibbolethAuth(authedIn: false)
            completionHandler(nil, nil, NetworkingError.authenticationError)
            return
        }
        
        let url = URL(string: loginUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var params: [String: String] = [
            "password": password,
            "submit1": "Log in",
            "passcode": passcode,
            "required": required,
            "appfactor": appfactor,
            "ref": ref,
            "service": service,
            "login": pennkey,
        ]
        
        if let reauth = html.getMatches(for: "name=\"reauth\" value=\"(.*?)\"").first {
            params["reauth"] = reauth
        }
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
                self.makeRequestWithShibboleth(targetUrl: targetUrl, shibbolethUrl: shibbolethUrl, html: html as String, completionHandler)
            } else {
                UserDefaults.standard.setShibbolethAuth(authedIn: false)
                completionHandler(nil, nil, NetworkingError.authenticationError)
            }
            UserDefaults.standard.storeCookies()
        }
        task.resume()
    }
    
    private func makeRequestWithShibboleth(targetUrl: String, shibbolethUrl: String, html: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let samlResponse = html.getMatches(for: "<input type=\"hidden\" name=\"SAMLResponse\" value=\"(.*?)\"/>").first,
            let relayState = html.getMatches(for: "<input type=\"hidden\" name=\"RelayState\" value=\"(.*?)\"/>").first?.replacingOccurrences(of: "&#x3a;", with: ":") else {
                HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
                UserDefaults.standard.setShibbolethAuth(authedIn: false)
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
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse, let urlStr = response.url?.absoluteString, urlStr == targetUrl {
                UserDefaults.standard.setShibbolethAuth(authedIn: true)
                completionHandler(data, response, error)
            } else {
                UserDefaults.standard.setShibbolethAuth(authedIn: false)
                completionHandler(nil, nil, NetworkingError.authenticationError)
            }
            UserDefaults.standard.storeCookies()
        }
        task.resume()
    }
}
