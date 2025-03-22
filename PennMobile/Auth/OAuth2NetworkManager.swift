//
//  OAuth2NetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 12/12/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import PennMobileShared
import OSLog

struct AccessToken: Codable {
    let value: String
    let expiration: Date
}

enum OAuth2State {
    case unknown
    case unauthenticated
    case authenticated(AccessToken)
    case acquiring(Task<AccessToken?, Error>)
}

@globalActor actor OAuth2NetworkManager {
    static let shared = OAuth2NetworkManager()
    static var instance: OAuth2NetworkManager {
        shared
    }
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    private let clientID = InfoPlistEnvironment.labsOauthClientId
    private let decoder = JSONDecoder()
    private var state = OAuth2State.unknown {
        willSet {
            if case .acquiring(let task) = state {
                task.cancel()
            }
        }
    }
    
    private static let logger = Logger(category: "OAuth2NetworkManager")
    
    private struct TokenResponse: Decodable {
        var expiresIn: Int
        var accessToken: String
        var refreshToken: String?
    }
}

// MARK: - Initiate Authentication
extension OAuth2NetworkManager {
    static let tokenURL = URL(string: "https://pennmobile.org/api/accounts/token/")!

    /// Input: One-time code from login
    /// Output: Temporary access token
    /// Saves refresh token in keychain for future use
    func initiateAuthentication(code: String, codeVerifier: String) async throws -> AccessToken? {
        var request = URLRequest(url: Self.tokenURL)
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

        let task = Task<AccessToken?, Error> {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let code = (response as? HTTPURLResponse)?.statusCode
                Self.logger.error("Response for auth token got unexpected status: \(code.map { "\($0)" } ?? "(not HTTP)", privacy: .public)")
                throw NetworkingError.serverError
            }
            
            guard !Task.isCancelled else {
                Self.logger.warning("initiateAuthentication task was cancelled")
                throw CancellationError()
            }
            
            let json = try decoder.decode(TokenResponse.self, from: data)
            let expiration = Date().add(seconds: json.expiresIn)
            let accessToken = AccessToken(value: json.accessToken, expiration: expiration)
            
            if let refreshToken = json.refreshToken {
                saveRefreshToken(token: refreshToken)
            }
            
            saveAccessToken(accessToken: accessToken)
            return accessToken
        }
        
        state = .acquiring(task)
        return try await task.value
    }
}

// MARK: - Get + Refresh Access Token
extension OAuth2NetworkManager {
    func getAccessToken() async throws -> AccessToken? {
        switch state {
        case .unknown:
            return try await refreshAccessToken()
        case .unauthenticated:
            return nil
        case .acquiring(let task):
            return try await task.value
        case .authenticated(let token):
            if Date() < token.expiration {
                return token
            } else {
                return try await refreshAccessToken()
            }
        }
    }

    func saveAccessToken(accessToken: AccessToken) {
        state = .authenticated(accessToken)
    }

    fileprivate func refreshAccessToken() async throws -> AccessToken? {
        guard let refreshToken = self.getRefreshToken() else {
            state = .unauthenticated
            return nil
        }

        var request = URLRequest(url: Self.tokenURL)
        request.httpMethod = "POST"

        let params = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token",
            "client_id": clientID
        ]

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = String.getPostString(params: params).data(using: String.Encoding.utf8)
        
        let task = Task<AccessToken?, Error> {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard !Task.isCancelled else {
                Self.logger.warning("refreshAccessToken task was cancelled")
                throw CancellationError()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Self.logger.error("URLSession did not return an HTTPURLResponse when refreshing token")
                throw NetworkingError.serverError
            }
            
            switch httpResponse.statusCode {
            case 200:
                let json = try decoder.decode(TokenResponse.self, from: data)
                let expiration = Date().add(seconds: json.expiresIn)
                let accessToken = AccessToken(value: json.accessToken, expiration: expiration)
//                let refreshToken = json.refreshToken
                
                if let refreshToken = json.refreshToken {
                    saveRefreshToken(token: refreshToken)
                }
                
                self.saveAccessToken(accessToken: accessToken)
                return accessToken
            case 400:
                struct InvalidRequestResponse: Decodable {
                    var detail: String
                }
                
                let json = try decoder.decode(InvalidRequestResponse.self, from: data)
                
                if json.detail == "Invalid parameters" {
                    // Refresh token is invalid, force user to sign in again
                    self.clearRefreshToken()
                    state = .unauthenticated
                    return nil
                } else {
                    Self.logger.error("Server returned unexpected refresh token error: \(json.detail, privacy: .public)")
                    throw NetworkingError.serverError
                }
            default:
                Self.logger.error("Server returned unexpected refresh token status: \("\(httpResponse.statusCode)", privacy: .public)")
                throw NetworkingError.serverError
            }
        }

        state = .acquiring(task)
        return try await task.value
    }
}

// MARK: - Save + Get Refresh Token
extension OAuth2NetworkManager {
    nonisolated private var service: String {
        return "LabsOAuth2"
    }

    nonisolated private var secureKey: String {
        return "Labs Refresh Token"
    }

    func saveRefreshToken(token: String) {
        let genericPwdQueryable =
            GenericPasswordQueryable(service: service)
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)

        try? secureStore.setValue(token, for: secureKey)
    }

    nonisolated fileprivate func getRefreshToken() -> String? {
        let genericPwdQueryable =
            GenericPasswordQueryable(service: service)
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)

        return try? secureStore.getValue(for: secureKey)
    }

    func clearRefreshToken() {
        let genericPwdQueryable =
            GenericPasswordQueryable(service: service)
        let secureStore =
            SecureStore(secureStoreQueryable: genericPwdQueryable)

        try? secureStore.removeValue(for: secureKey)
    }

    func clearCurrentAccessToken() {
        state = .unauthenticated
    }

    nonisolated func hasRefreshToken() -> Bool {
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

// MARK: - Utilities

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
    
    init(authenticatedUrl: URL, authNetworkManager: OAuth2NetworkManager = .shared) async throws {
        guard let token = try await authNetworkManager.getAccessToken() else {
            throw NetworkingError.authenticationError
        }
        
        self.init(url: authenticatedUrl, accessToken: token)
    }
}

// MARK: - Legacy Support

extension OAuth2NetworkManager {
    @available(*, deprecated)
    nonisolated func getAccessToken(_ callback: @escaping (_ accessToken: AccessToken?) -> Void) {
        Task {
            callback(try? await getAccessToken())
        }
    }
    
    @available(*, deprecated)
    nonisolated func initiateAuthentication(code: String, codeVerifier: String, _ callback: @escaping (_ accessToken: AccessToken?) -> Void) {
        Task {
            callback(try? await initiateAuthentication(code: code, codeVerifier: codeVerifier))
        }
    }
}
