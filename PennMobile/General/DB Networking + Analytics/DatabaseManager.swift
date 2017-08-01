//
//  DatabaseManager.swift
//  PennMobile
//
//  Created by Josh Doman on 6/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DatabaseManager: NSObject, Requestable {
    
    static let shared = DatabaseManager()
    let dbURL = "https://agile-waters-48349.herokuapp.com/"
    
    private var batchRequests = [DBRequest]()
    
    var dryRun: Bool = false //prevents any requests being sent
    
    func append(toQueue request: DBRequest) {
        self.batchRequests.append(request)
    }
    
    func sendCurrentBatch() throws {
        try request(method: .post, url: dbURL, params: batchRequests.encode())
        batchRequests.removeAll() //only runs if error not thrown
    }
}

//Mark: Handle First Sessions
extension DatabaseManager {
    func startSession() {
        if UserDefaults.standard.isFirstTimeUser(), let deviceUUID = UIDevice.current.identifierForVendor?.uuidString {
          UserDefaults.standard.setDeviceUUID(value: deviceUUID)
        }
        //if UserDefaults.standard.string(forKey: "deviceId") == nil, let deviceId = UIDevice.current.identifierForVendor?.uuidString {
        
        //}
    }
}

class DBRequest: NSObject {
    let method: Method
    let uri: String
    let params: [String: Any]?
    
    init(method: Method, uri: String, params: [String: Any]? = nil, values: Any? = nil) {
        self.method = method
        self.uri = uri
        self.params = params
    }
    
    func encode() -> [String: Any] {
        let values: Any = params == nil ? "null" : params!
        return [
            "method": method.description,
            "uri": uri,
            "values": values
        ]
    }
}

extension Array where Element: DBRequest {
    func encode() -> [String: Any] {
        return ["requests": self]
    }
}
