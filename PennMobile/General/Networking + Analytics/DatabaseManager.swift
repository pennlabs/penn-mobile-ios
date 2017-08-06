//
//  DatabaseManager.swift
//  PennMobile
//
//  Created by Josh Doman on 6/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

enum DBError: String, LocalizedError {
    case deviceUUIDUnavailable = "Device UUID Unavailable. Check to make sure that it has not been removed from UserDefaults or being accessed before it has been set."
    var localizedDescription: String { return NSLocalizedString(self.rawValue, comment: "") }
}

@objc class DatabaseManager: NSObject, Requestable {
    
    static let shared = DatabaseManager()
    static let dbURL = "https://agile-waters-48349.herokuapp.com"
    
    var maxBatchSize = 5 //maximum number of batchRequests
    
    fileprivate var batchTimer: Timer?
    var maxTime: TimeInterval = 30 //default batch time is 30 seconds
    
    internal var batchRequests = [DBRequest]() {
        didSet {
            if batchRequests.count >= maxBatchSize {
                sendCurrentBatch()
            } else if batchRequests.count == 1 { //first request added
                batchTimer = Timer.scheduledTimer(timeInterval: maxTime, target: self, selector: #selector(sendCurrentBatch), userInfo: nil, repeats: false)
            }
        }
    }
    
    internal var sessionStarted = false
    
    var dryRun: Bool = false //prevents any requests being sent
    
    func append(toQueue request: DBRequest) {
        self.batchRequests.append(request)
    }
    
    func sendCurrentBatch() {
        if dryRun && !batchRequests.isEmpty { return }
        
        do {
            let url = DatabaseManager.dbURL + "/batch"
            try request(method: .post, url: url, params: batchRequests.encode())
            batchRequests.removeAll() //only runs if error not thrown
            batchTimer?.invalidate()
        } catch {
            print("Caught: \(error)")
        }
    }
}

//Mark: Handles creation and end of sessions (including creation of user)
extension DatabaseManager {
    
    //returns true if successful, false if not a first time user
    //NOTE: returns true if user has deleted the app in the past and has just redownloaded it
    func createUser(with deviceToken: String? = nil) throws -> Bool {
        let isFirstTimeUser = UserDefaults.standard.isFirstTimeUser()
        if isFirstTimeUser, let deviceUUID = UIDevice.current.identifierForVendor?.uuidString {
            UserDefaults.standard.set(deviceUUID: deviceUUID)
            
            if let token = deviceToken {
                UserDefaults.standard.set(deviceToken: token)
            }
            
            let uri = DatabaseManager.dbURL + "/users"
            var params: [String: Any] = ["device_id": deviceUUID]
            params["token"] = deviceToken
            batchRequests.append(DBRequest(method: .post, uri: uri, params: params))
        }
        return isFirstTimeUser
    }
    
    func updateDeviceToken(with deviceToken: String) throws {
        let uri = DatabaseManager.dbURL + "/users"
        guard let deviceId = UserDefaults.standard.getDeviceUUID() else {
            throw DBError.deviceUUIDUnavailable
        }
        let params = [
            "deviceId": deviceId,
            "token": deviceToken
            ]
        batchRequests.append(DBRequest(method: .patch, uri: uri, params: params))
    }
    
    func startSession() {
        if sessionStarted { return }
        
        sessionStarted = true
        UserDefaults.standard.incrementSessionCount() //sets count to 0 if first time, +1 otherwise
        
        if UserDefaults.standard.isFirstTimeUser() {
            return
        }
        do {
            try logSessionStarted()
        } catch {
            print("Caught: \(error)")
        }
    }
    
    func endSession() {
        if !sessionStarted { return }
        
        do {
            try logSessionEnded()
        } catch {
            print("Caught: \(error)")
        }
        
        sessionStarted = false
        sendCurrentBatch()
    }
    
    internal func logSessionStarted() throws {
        let vc = ControllerSettings.shared.visibleVCName()
        batchRequests.append(try DBLogRequest(vc: vc, event: "Session started", action: nil, desc: nil))
    }
    
    internal func logSessionEnded() throws {
        batchRequests.append(try DBLogRequest(event: "Session ended"))
    }
}

//Mark: Trackable API
extension DatabaseManager {
    func trackVC(_ name: String) {
        do {
            batchRequests.append(try DBLogRequest(vc: name, event: "New VC", action: nil, desc: nil))
        } catch {
        }
    }
    
    func trackEvent(vcName: String, event: String, action: String? = nil) {
        do {
            batchRequests.append(try DBLogRequest(vc: vcName, event: event, action: action, desc: nil))
        } catch {
        }
    }
}

class DBLogRequest: DBRequest {
    
    init(vc: String? = nil, event: String? = nil, action: String? = nil, desc: String? = nil) throws {
        let uri = DatabaseManager.dbURL + "/logs"
        guard let deviceId = UserDefaults.standard.getDeviceUUID() else {
            throw DBError.deviceUUIDUnavailable
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZ"
        let params = [
            "device_id": deviceId,
            "session": UserDefaults.standard.getSessionCount(),
            "vc": vc,
            "event": event,
            "action": action,
            "desc": desc,
            "timestamp": formatter.string(from: Date())
        ].removeNullValues()
        super.init(method: .post, uri: uri, params: params)
    }
}

class DBRequest: NSObject {
    let method: Method
    let uri: String
    let params: [String: Any]?
    
    init(method: Method, uri: String, params: [String: Any]? = nil) {
        self.method = method
        self.uri = uri
        self.params = params
    }
    
    func encode() -> [NSString: Any] {
        var dict: [NSString: Any] = [
            "method": method.description as NSString,
            "uri": uri as NSString
        ]
        dict["values"] = params as [NSString: Any]?
        return dict
    }
}

extension Array where Element: DBRequest {
    func encode() -> [NSString: Any] {
        let encodedRequests = self.map { (req) -> [NSString: Any] in
            return req.encode()
        } as Any
        return ["requests": encodedRequests]
    }
}

extension Dictionary where Key == String, Value == Optional<Any> {
    func unwrapOptionals(withNullUnwrap: Bool) -> [String: Any]{
        var dict = [String: Any]()
        for (k,v) in self {
            if v != nil || withNullUnwrap {
                dict[k] = v.nullUnwrap()
            }
        }
        return dict
    }
    
    func removeNullValues() -> [String: Any] {
        return self.unwrapOptionals(withNullUnwrap: false)
    }
}
