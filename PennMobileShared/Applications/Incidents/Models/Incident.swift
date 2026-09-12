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
