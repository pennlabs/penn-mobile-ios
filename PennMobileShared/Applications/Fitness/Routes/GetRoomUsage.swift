//
//  GetRoomUsage.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Fitness {
    struct GetRoomUsage: PennMobileEndpoint {
        public typealias Response = FitnessRoomData
        public let path: String
        public let queryParams: [String: String]?
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd")

        public init(roomId: Int, date: Date = Date(), numSamples: Int = 3, groupBy: String = "week", field: String = "count") {
            self.path = "/penndata/fitness/usage/\(roomId)/"
            self.queryParams = [
                "date": DateFormatter.yyyyMMdd.string(from: date),
                "num_samples": String(numSamples),
                "group_by": groupBy,
                "field": field
            ]
        }
    }
}
