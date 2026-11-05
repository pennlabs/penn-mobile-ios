//
//  EndpointBackend.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import LabsPlatformSwift

public enum EndpointBackend: Sendable {
    case pennMobile
    case platform
    case pennClubs
    case pennCourseAlert
    case pennCoursePlan
    case pennLabsStatus
    case campusExpress
    case custom(baseURL: String)
    
    public var rawValue: Int {
        switch self {
        case .pennMobile:
            return 0
        case .platform:
            return 1
        case .pennClubs:
            return 2
        case .pennCourseAlert:
            return 3
        case .pennCoursePlan:
            return 4
        case .pennLabsStatus:
            return 5
        case .campusExpress:
            return 6
        case .custom(let baseURL):
            var hasher = Hasher()
            hasher.combine(baseURL)
            return hasher.finalize()
        }
    }

    public var baseURL: String {
        switch self {
        case .pennMobile: "https://pennmobile.org/api"
        case .platform: "https://platform.pennlabs.org"
        case .pennClubs: "https://pennclubs.com/api"
        case .pennCourseAlert: "https://penncoursealert.com"
        case .pennCoursePlan: "https://penncourseplan.com/api"
        case .pennLabsStatus: "https://status.pennlabs.org"
        case .campusExpress: "https://prod.campusexpress.upenn.edu/api/v1"
        case .custom(let baseURL): baseURL
        }
    }

    /// Builds a URLRequest authenticated the way this backend expects.
    public func authenticatedRequest(url: URL) async throws -> URLRequest {
        switch self {
        case .pennMobile, .platform, .pennClubs, .pennCourseAlert, .pennCoursePlan:
            try await URLRequest(url: url, mode: .accessToken)
        default:
            URLRequest(url: url)
        }
    }
}
