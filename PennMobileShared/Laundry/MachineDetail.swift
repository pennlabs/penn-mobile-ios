//
//  MachineDetail.swift
//  PennMobileShared
//
//  Created by Nathan Aronson on 11/23/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

public struct MachineDetail: Codable, Hashable, Sendable {
    public let id: String
    public let type: MachineType
    public let status: Status
    public let timeRemaining: Int
    
    public enum MachineType: String, Codable, Sendable {
        case washer, dryer
    }
    
    public enum Status: String, Codable, Sendable {
        case available = "AVAILABLE"
        case complete = "COMPLETE"
        case inUse = "IN_USE"
        case error = "ERROR"
        case networkError = "NETWORK_ERROR"
        case unavailable = "UNAVAILABLE"
        case unknown
        
        public func imageName(for type: MachineType) -> String {
            switch self {
            case .available, .complete:
                return type == .washer ? "washer_open" : "dryer_open"
            case .inUse:
                return type == .washer ? "washer_busy" : "dryer_busy"
            case .error, .networkError, .unavailable, .unknown:
                return type == .washer ? "washer_broken" : "dryer_broken"
            }
        }
    }
}
