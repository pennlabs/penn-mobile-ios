//
//  OAuth2NetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 12/12/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AccessToken: Codable {
    let value: String
    let expiration: Date
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

    private var clientID = InfoPlistEnvironment.labsOauthClientId

    private var currentAccessToken: AccessToken?
}

// MARK: - Initiate Authentication
extension OAuth2NetworkManager {
    /// Input: One-time code from login
    /// Output: Temporary access token
    /// Saves refresh token in keychain for future use
    func initiateAuthentication(code: String, codeVerifier: String, _ callback: @escaping (_ accessToken: AccessToken?) -> Void) {
        let url = URL(string: "https://platform.pennlabs.org/accounts/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "code": code,
            "grant_type": "authorization_code",
            "client_id": clientID,
            "redirect_uri": "https://pennlabs.org/pennmobile/ios/callback/",
            "code_verifier": codeVerifier
        ]

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = String.getPostString(params: params).data(using: String.Encoding.utf8)

        let task = URLSession.shared.dataTask(with: request) { (data, response, _) in
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
        // dev token that expires in a year
        // use until auth is back up
        if let accessToken = self.currentAccessToken, Date() < accessToken.expiration {
            callback(accessToken)
        } else {
            self.currentAccessToken = nil
            self.refreshAccessToken(callback)
        }
    }

    func saveAccessToken(accessToken: AccessToken) {
        self.currentAccessToken = accessToken
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
            "client_id": clientID
        ]

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = String.getPostString(params: params).data(using: String.Encoding.utf8)

        let task = URLSession.shared.dataTask(with: request) { (data, response, _) in
            DispatchQueue.global().async {
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
                            // This refresh token is invalid.
                            if let accessToken = self.currentAccessToken, refreshToken != self.getRefreshToken() {
                                // Access token has been refreshed in another network call while we were waiting and current refresh token is not the same one we used
                                callback(accessToken)
                                return
                            }

                            // Clear refresh token and force user to log in
                            self.clearRefreshToken()
                        }
                    }
                }
                callback(nil)
            }
        }
        task.resume()

    }
}

// MARK: - Retrieve Account
extension OAuth2NetworkManager {
    func retrieveAccount(accessToken: AccessToken, _ callback: @escaping (_ user: Account?) -> Void) {
        let url = URL(string: "https://platform.pennlabs.org/accounts/me/")!
        let request = URLRequest(url: url, accessToken: accessToken)

        let task = URLSession.shared.dataTask(with: request) { (data, response, _) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let user = try? decoder.decode(Account.self, from: data)
                callback(user)
                return
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

    func saveRefreshToken(token: String) {
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

    func clearCurrentAccessToken() {
        currentAccessToken = nil
    }

    func hasRefreshToken() -> Bool {
        return getRefreshToken() != nil
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
            } else if let arr = value as? [Any] {
                let str = arr.map { String(describing: $0).addingPercentEncoding(withAllowedCharacters: characterSet) ?? "" }.joined(separator: ",")
                return "\(escapedKey)=\(str)"
            } else {
                return "\(escapedKey)=\(value)"
            }
        }
        let encodedParams = parameterArray.joined(separator: "&")
        return encodedParams
    }
}
