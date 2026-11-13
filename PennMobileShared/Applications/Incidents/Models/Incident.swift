//
//  Incident.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public struct Incident: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let createdAt: Date
    public let affectedServices: [String]
    public let status: String
    public let severity: IncidentSeverity
    public let updates: [IncidentUpdate]
}

public extension Array where Element == Incident {
    /// Unresolved incidents affecting Penn Mobile, most severe first.
    var relevant: [Incident] {
        self
            .filter { incident in
                let isMobile = incident.affectedServices.contains("mobile-backend") ||
                    incident.affectedServices.contains("mobile-ios")
                return isMobile && incident.status != "resolved"
            }
            .sorted { $0.severity.rawValue > $1.severity.rawValue }
    }
}
