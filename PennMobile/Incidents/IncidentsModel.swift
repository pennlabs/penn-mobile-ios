//
//  Incident.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

struct Incident: Identifiable, Codable {
    let id: String
    let title: String
    let createdAt: Date
    let affectedServices: [String]
    let status: String
    let severity: IncidentSeverity
    let updates: [IncidentUpdate]
}

struct IncidentUpdate: Identifiable, Codable {
    let id: String
    let message: String
    let status: String
    let timestamp: Date
}

enum IncidentSeverity: Int, Codable {
    case severe = 2
    case degraded = 1
    case info = 0
    
    var systemImage: String {
        switch self {
        case .severe:
            "xmark.octagon.fill"
        case .degraded:
            "exclamationmark.triangle.fill"
        case .info:
            "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .severe:
                .red
        case .degraded:
                .yellow
        case .info:
                .gray
        }
    }
}
