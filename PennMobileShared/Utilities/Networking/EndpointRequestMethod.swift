//
//  EndpointRequestMethod.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/30/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public enum EndpointRequestMethod: Sendable {
    /// - Parameter cacheAge: How long a cached result stays usable, in seconds. `nil` means the result isn't cached.
    case get(cacheAge: TimeInterval? = nil)
    case post
    case put
    case patch
    case delete

    public static let defaultCacheAge: TimeInterval = 7 * 24 * 60 * 60

    public var rawValue: String {
        switch self {
        case .get:
            "GET"
        case .post:
            "POST"
        case .put:
            "PUT"
        case .patch:
            "PATCH"
        case .delete:
            "DELETE"
        }
    }
}
