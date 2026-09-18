//
//  GSRLocation.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

public struct GSRLocation: Codable, Equatable, Hashable, Sendable {
    public let lid: String
    public let gid: Int
    public let name: String
    public let kind: GSRServiceType
    public let imageUrl: String
    public let bookableDays: Int

    public enum GSRServiceType: String, Codable, Hashable, Sendable {
        case wharton = "WHARTON"
        case libcal = "LIBCAL"
        case penngroups = "PENNGRP"
        
        public var maxConsecutiveBookings: Int {
            switch self {
            case .wharton:
                return 3
            case .libcal, .penngroups:
                return 4
            }
        }
    }
}
