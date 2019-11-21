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
    
    private var baseUrl: String {
        return "https://weblogin.pennkey.upenn.edu"
    }
    
    private var authUrl: String {
        return "https://weblogin.pennkey.upenn.edu/idp/profile"
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
        guard let actionUrl = html.getMatches(for: "form action=\"(.*?)\" method=\"POST\" id=\"login-form\"").first else {
            UserDefaults.standard.setShibbolethAuth(authedIn: false)
            completionHandler(nil, nil, NetworkingError.authenticationError)
            return
        }
        
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
        
        guard pennkey != nil && password != nil else {
            UserDefaults.standard.setShibbolethAuth(authedIn: false)
            completionHandler(nil, nil, NetworkingError.authenticationError)
            return
        }
        
        let url = URL(string: baseUrl + actionUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "j_username": pennkey,
            "j_password": password,
            "_eventId_proceed": "",
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
            UserDefaults.standard.storeCookies()
            if let response = response as? HTTPURLResponse, let urlStr = response.url?.absoluteString, urlStr == targetUrl {
                UserDefaults.standard.setShibbolethAuth(authedIn: true)
                completionHandler(data, response, error)
            } else {
                UserDefaults.standard.setShibbolethAuth(authedIn: false)
                completionHandler(nil, nil, NetworkingError.authenticationError)
            }
        }
        task.resume()
    }
}
