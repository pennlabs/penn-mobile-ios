//
//  IncidentUpdate.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public struct IncidentUpdate: Identifiable, Codable, Sendable {
    public let id: String
    public let message: String
    public let status: String
    public let timestamp: Date
}
