//
//  NotificationDeviceTokenManager.swift
//  PennMobile
//
//  Created by Anthony Li on 11/18/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import PennMobileShared
import OSLog

@globalActor actor NotificationDeviceTokenManager {
    private static let logger = Logger(category: "NotificationDeviceTokenManager")
    
    enum TokenAction {
        case sendToken
        case deleteToken
    }
    
    static let shared = NotificationDeviceTokenManager()
    
    private var cachedToken: (data: Data, fromMemory: Bool, actionTaken: TokenAction?)?
    private var pendingAction: TokenAction?
    
    private var currentTask: Task<Void, Error>?
    
    private let storageName = "notificationDeviceToken"
    
    private init() {
        if let token = try? Storage.retrieveThrowing(storageName, from: .caches, as: Data.self) {
            cachedToken = (data: token, fromMemory: false, actionTaken: nil)
            Self.logger.info("Notification token restored from cache (\(token.count) bytes)")
        }
    }
    
    func tokenReceived(_ token: Data) {
        Self.logger.info("Notification token received from app delegate (\(token.count) bytes)")
        
        let oldToken = cachedToken
        cachedToken = (data: token, fromMemory: true, actionTaken: pendingAction)
        
        guard let pendingAction else {
            return
        }
                
        if let oldToken, oldToken.actionTaken == pendingAction, oldToken.data == token {
            return
        }
        
        currentTask?.cancel()
        switch pendingAction {
        case .deleteToken:
            currentTask = Task {
                try? await delete(token: token)
            }
        case .sendToken:
            currentTask = Task {
                try? await send(token: token)
            }
        }
        
        try? Storage.storeThrowing(token, to: .caches, as: storageName)
    }
    
    func authStateDetermined(_ state: AuthState) {
        Self.logger.debug("Notification token manager got auth state: \(state.debugDescription)")
        
        switch state {
        case .loggedIn:
            if pendingAction != .sendToken {
                currentTask?.cancel()
                pendingAction = .sendToken
                
                if let cachedToken, cachedToken.fromMemory {
                    self.cachedToken!.actionTaken = .sendToken
                    
                    currentTask = Task {
                        try? await send(token: cachedToken.data)
                    }
                }
            }
        case .loggedOut, .guest:
            if pendingAction != .deleteToken {
                currentTask?.cancel()
                pendingAction = .deleteToken
                
                if let cachedToken {
                    self.cachedToken!.actionTaken = .deleteToken
                    
                    currentTask = Task {
                        try? await delete(token: cachedToken.data)
                    }
                }
            }
        }
    }
    
    private func url(for token: Data) -> URL {
        let hex = token.map { byte -> String in
            return String(format: "%02.2hhx", byte)
        }.joined()
        
        return URL(string: "https://pennmobile.org/api/user/notifications/tokens/ios/\(hex)/")!
    }
    
    private func send(token: Data) async throws {
        do {
            Self.logger.info("Uploading notification token")
           
            let url = url(for: token)
            var request = try await URLRequest(authenticatedUrl: url)
            request.httpMethod = "POST"
            
            struct TokenUploadRequest: Encodable {
    #if DEBUG
                var is_dev = true
    #else
                var is_dev = false
    #endif
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(TokenUploadRequest())
            
            let data: Data
            let response: URLResponse
            
            do {
                (data, response) = try await URLSession.shared.data(for: request)
            } catch {
                Self.logger.error("Couldn't upload notification token: \(error)")
                throw error
            }
            
            guard let response = response as? HTTPURLResponse else {
                Self.logger.error("Couldn't upload notification token: got unexpected response type")
                throw NetworkingError.serverError
            }
            
            guard (200..<300).contains(response.statusCode) else {
                Self.logger.error("Couldn't upload notification token: got unexpected status code \(response.statusCode)")
                throw NetworkingError.serverError
            }
            
            if let str = String(data: data, encoding: .utf8) {
                Self.logger.info("Notification token uploaded, response: \(str)")
            } else {
                Self.logger.info("Notification token uploaded, response not decodable")
            }
        } catch {
            Self.logger.error("Couldn't upload notification token: \(error)")
        }
    }
    
    private func delete(token: Data) async throws {
        Self.logger.info("Deleting notification token")
        
        let url = url(for: token)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            Self.logger.error("Couldn't delete notification token: \(error)")
            throw error
        }
        
        guard let response = response as? HTTPURLResponse else {
            Self.logger.error("Couldn't delete notification token: got unexpected response type")
            throw NetworkingError.serverError
        }
        
        guard (200..<300).contains(response.statusCode) else {
            Self.logger.error("Couldn't delete notification token: got unexpected status code \(response.statusCode)")
            throw NetworkingError.serverError
        }
        
        if let str = String(data: data, encoding: .utf8) {
            Self.logger.info("Notification token deleted, response: \(str)")
        } else {
            Self.logger.info("Notification token deleted, response not decodable")
        }
    }
}
