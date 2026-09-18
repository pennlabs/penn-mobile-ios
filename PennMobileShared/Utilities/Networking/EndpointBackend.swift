//
//  EndpointBackend.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

public enum EndpointBackend: Sendable {
    case pennMobile
    case pennClubs
    case pennCourseAlert
    case pennCoursePlan
    case pennLabsStatus
    case campusExpress
    case custom(baseURL: String)

    public var baseURL: String {
        switch self {
        case .pennMobile: "https://pennmobile.org/api"
        case .pennClubs: "https://pennclubs.com/api"
        case .pennCourseAlert: "https://penncoursealert.com"
        case .pennCoursePlan: "https://penncourseplan.com/api"
        case .pennLabsStatus: "https://status.pennlabs.org"
        case .campusExpress: "https://prod.campusexpress.upenn.edu/api/v1"
        case .custom(let baseURL): baseURL
        }
    }
}
