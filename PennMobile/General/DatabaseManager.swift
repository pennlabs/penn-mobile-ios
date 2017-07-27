//
//  DatabaseManager.swift
//  PennMobile
//
//  Created by Josh Doman on 6/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DatabaseManager: NSObject {
    
    static let shared = DatabaseManager()
    
    //fileprivate var requests = [DBRequest]()
    
    var dryRun: Bool = false //prevents any requests being sent
    
    func startSession() {
        //if UserDefaults.standard.string(forKey: "deviceId") == nil, let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            
        //}
    }
}

//private class DBRequest: NSObject {
//    
//    static let dbURL = "https://agile-waters-48349.herokuapp.com/"
//    
//    let method: Method
//    let url: URL
//    
//    init(method: Method, path: String, values: Any) throws {
//        self.method = method
//        guard let url = URL(string: DBRequest.dbURL + path) else {
//            return //throw EXC_CRASH
//        }
//    }
//    
//}


public enum Method {
    case delete
    case get
    case head
    case post
    case put
    case connect
    case options
    case trace
    case patch
    case other(method: String)
}

extension Method {
    public init(_ rawValue: String) {
        let method = rawValue.uppercased()
        switch method {
        case "DELETE":
            self = .delete
        case "GET":
            self = .get
        case "HEAD":
            self = .head
        case "POST":
            self = .post
        case "PUT":
            self = .put
        case "CONNECT":
            self = .connect
        case "OPTIONS":
            self = .options
        case "TRACE":
            self = .trace
        case "PATCH":
            self = .patch
        default:
            self = .other(method: method)
        }
    }
}

extension Method: CustomStringConvertible {
    public var description: String {
        switch self {
        case .delete:            return "DELETE"
        case .get:               return "GET"
        case .head:              return "HEAD"
        case .post:              return "POST"
        case .put:               return "PUT"
        case .connect:           return "CONNECT"
        case .options:           return "OPTIONS"
        case .trace:             return "TRACE"
        case .patch:             return "PATCH"
        case .other(let method): return method.uppercased()
        }
    }
}
