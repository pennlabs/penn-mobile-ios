//
//  PennMobileNetworkCall.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public protocol PennMobileEndpoint: Sendable {
    var path: String { get }
    var method: String { get }
    var authenticated: Bool { get }
    var queryParams: [String: String]? { get }
    var bodyJSON: (any Encodable & Sendable)? { get }
    associatedtype Response: Decodable
    
    var requestBodyEncoder: JSONEncoder? { get }
    var responseDecoder: JSONDecoder? { get }
    
    var cacheResult: Bool { get }
}
