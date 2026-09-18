//
//  IncidentSeverity.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

public enum IncidentSeverity: Int, Codable, Sendable {
    case severe = 2
    case degraded = 1
    case info = 0
    
    public var systemImage: String {
        switch self {
        case .severe:
            "xmark.octagon.fill"
        case .degraded:
            "exclamationmark.triangle.fill"
        case .info:
            "info.circle.fill"
        }
    }
    
    public var color: Color {
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
