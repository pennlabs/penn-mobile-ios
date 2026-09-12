//
//  GetVenues.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct GetVenues: PennMobileEndpoint {
        public typealias returns = [DiningVenue]
        public let path: String = "/dining/venues"
        public let method: String = "GET"
        public let authenticated: Bool = false
        public let queryParams: [String : String]? = nil
        public let bodyJSON: (any Encodable)? = nil
        public let cacheResult: Bool = false
        
        public let responseDecoder: JSONDecoder? = {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            return decoder
        }()
        
        public let requestBodyEncoder: JSONEncoder? = nil
        
        public init() {}
    }
}
