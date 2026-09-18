//
//  JSONDecoder+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

public extension JSONDecoder.DateDecodingStrategy {
    static let iso8601Full = custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        if let date = DateFormatter.iso8601Full.date(from: dateString) {
            return date
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
        }
    }
}

public extension JSONDecoder {
    convenience init(keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
    }
}

public extension JSONDecoder {
    static var snakeCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    static func formatted(_ dateFormat: String, keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys) -> JSONDecoder {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return JSONDecoder(keyDecodingStrategy: keyDecodingStrategy, dateDecodingStrategy: .formatted(formatter))
    }
    
    static var snakeCaseFlexibleDates: JSONDecoder {
        JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .custom({ decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = DateFormatter.iso8601.date(from: dateString) ?? DateFormatter.iso8601Full.date(from: dateString) ?? DateFormatter.yyyyMMdd.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }))
    }
}
