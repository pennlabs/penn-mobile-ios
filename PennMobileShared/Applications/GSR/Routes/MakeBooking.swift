//
//  MakeBooking.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.GSR {
    struct MakeBooking: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path = "/gsr/book/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = {
            let formatter = DateFormatter()
            formatter.locale = .enUS
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .formatted(formatter)
            return encoder
        }()

        public init(booking: GSRBooking) {
            self.bodyJSON = booking
        }
    }
}
