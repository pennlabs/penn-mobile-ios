//
//  OAuth2NetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 12/12/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct AccessToken: Codable {
    let value: String
    let expiration: Date
}

struct OAuthUser: Codable {
    let firstName: String
    let lastName: String
    let pennid: Int
    let username: String
    let email: String?
    let affiliation: [String]
}

extension URLRequest {
    // Sets the appropriate header field given an access token
    // NOTE: Should ONLY be used for requests to Labs servers. Otherwise, access token will be compromised.
    init(url: URL, accessToken: AccessToken) {
        self.init(url: url)
        // Authorization headers are restricted on iOS and not supposed to be set. They can be removed at any time.
        // Thus, we et an X-Authorization header to carry the bearer token in addition to the regular Authorization header.
        // For more info: see https://developer.apple.com/documentation/foundation/nsurlrequest#1776617
        setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "Authorization")
        setValue("Bearer \(accessToken.value)", forHTTPHeaderField: "X-Authorization")
    }
}

class OAuth2NetworkManager: NSObject {
    static let instance = OAuth2NetworkManager()
    private override init() {}
    
    private var clientID = "CJmaheeaQ5bJhRL0xxlxK3b8VEbLb3dMfUAvI2TN"
    
    private var currentAccessToken: AccessToken?
}

// MARK: - Initiate Authentication
extension OAuth2NetworkManager {
    /// Input: One-time code from login
    /// Output: Temporary access token
    /// Saves refresh token in keychain for future use
    func initiateAuthentication(code: String, _ callback: @escaping (_ accessToken: AccessToken?) -> Void) {
        let url = URL(string: "https://platform.pennlabs.org/accounts/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let randomStr = String.randomString(length: 64)
        let params = [
            "code": code,
            "grant_type": "authorization_code",
            "client_id": clientID,
            "redirect_uri": "https://pennlabs.org/pennmobile/ios/callback/",
            "code_verifier": randomStr,
        ]
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = String.getPostString(params: params).data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                let json = JSON(data)
                let expiresIn = json["expires_in"].intValue
                let expiration = Date().add(seconds: expiresIn)
                let accessToken = AccessToken(value: json["access_token"].stringValue, expiration: expiration)
                let refreshToken = json["refresh_token"].stringValue
                self.saveRefreshToken(token: refreshToken)
                self.currentAccessToken = accessToken
                callback(accessToken)
                return
            }
            callback(nil)
        }
        task.resume()
    }
}

// MARK: - Get + Refresh Access Token
extension OAuth2NetworkManager {
    func getAccessToken(_ callback: @escaping (_ accessToken: AccessToken?) -> Void) {
        if let accessToken = self.currentAccessToken, Date() < accessToken.expiration {
            callback(accessToken)
        } else {
            self.refreshAccessToken(callback)
        }
    }
    
    fileprivate func refreshAccessToken(_ callback: @escaping (_ accessToken: AccessToken?) -> Void ) {
        guard let refreshToken = self.getRefreshToken() else {
            callback(nil)
            return
        }
        
        let url = URL(string: "https://platform.pennlabs.org/accounts/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let params = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token",
            "client_id": clientID,
        ]
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = String.getPostString(params: params).data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, let data = data {
                if httpResponse.statusCode == 200 {
                    let json = JSON(data)
                    let expiresIn = json["expires_in"].intValue
                    let expiration = Date().add(seconds: expiresIn)
                    let accessToken = AccessToken(value: json["access_token"].stringValue, expiration: expiration)
                    let refreshToken = json["refresh_token"].stringValue
                    self.saveRefreshToken(token: refreshToken)
                    self.currentAccessToken = accessToken
                    callback(accessToken)
                    return
                } else if httpResponse.statusCode == 400 {
                    let json = JSON(data)
                    if json["error"].stringValue == "invalid_grant" {
                        // Refresh token is invalid. Clear it to force user to log in
                        self.clearRefreshToken()
                    }
                }
            }
            callback(nil)
        }
        task.resume()
        
    }
}

// MARK: - Retrieve Account
extension OAuth2NetworkManager {
    func retrieveAccount(accessToken: AccessToken, _ callback: @escaping (_ user: OAuthUser?) -> Void) {
        let url = URL(string: "https://platform.pennlabs.org/accounts/introspect/")!
        var request = URLRequest(url: url, accessToken: accessToken)
        request.httpMethod = "POST"
        
        let params = [
            "token": accessToken.value,
        ]
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = String.getPostString(params: params).data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                let json = JSON(data)
                if let userData = try? json["user"].rawData() {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let user = try? decoder.decode(OAuthUser.self, from: userData)
                    callback(user)
                    return
                }
            }
            callback(nil)
        }
        task.resume()
    }
}

// MARK: - Save + Get Refresh Token
extension OAuth2NetworkManager {
    private var service: String {
        return "LabsOAuth2"
    }
    
    private var secureKey: String {
        return "Labs Refresh Token"
    }
    
    fileprivate func saveRefreshToken(token: String) {
        let genericPwdQueryable =
            GenericPasswordQueryable(service: service)
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)
        
        try? secureStore.setValue(token, for: secureKey)
    }
    
    fileprivate func getRefreshToken() -> String? {
        let genericPwdQueryable =
            GenericPasswordQueryable(service: service)
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)
        
        let refreshToken: String?
        do {
            refreshToken = try secureStore.getValue(for: secureKey)
        } catch {
            refreshToken = nil
        }
        
        return refreshToken
    }
    
    func clearRefreshToken() {
        let genericPwdQueryable =
            GenericPasswordQueryable(service: service)
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)
        
        try? secureStore.removeValue(for: secureKey)
    }
    
    func hasRefreshToken() -> Bool {
        return getRefreshToken() != nil
    }
}

// Source: https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift/33860834
extension String {
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension String {
    static func getPostString(params: [String: Any]) -> String {
        let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let parameterArray = params.map { key, value -> String in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
            if let strValue = value as? String {
                let escapedValue = strValue.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
                return "\(escapedKey)=\(escapedValue)"
            } else {
                return "\(escapedKey)=\(value)"
            }
        }
        let encodedParams = parameterArray.joined(separator: "&")
        return encodedParams
    }
}
