//
//  PennMobileNetworkCall.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public protocol PennMobileEndpoint: Sendable {
    var backend: EndpointBackend { get }
    var path: String { get }
    var method: String { get }
    var authenticated: Bool { get }
    var headers: [String: String]? { get }
    var queryParams: [String: String]? { get }
    var bodyJSON: (any Encodable & Sendable)? { get }
    var bodyData: Data? { get }
    associatedtype Response: Decodable
    
    var requestBodyEncoder: JSONEncoder? { get }
    var responseDecoder: JSONDecoder? { get }
    
    var cacheResult: Bool { get }
}

public extension PennMobileEndpoint {
    var backend: EndpointBackend { .pennMobile }
    var method: String { "GET" }
    var authenticated: Bool { false }
    var headers: [String: String]? { nil }
    var queryParams: [String: String]? { nil }
    var bodyJSON: (any Encodable & Sendable)? { nil }
    var bodyData: Data? { nil }
    var requestBodyEncoder: JSONEncoder? { nil }
    var responseDecoder: JSONDecoder? { nil }
    var cacheResult: Bool { false }

    @discardableResult
    func execute() async throws -> Response {
        try await PennMobileBackend.executeEndpoint(self)
    }
}
