//
//  DiningToken.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 1/28/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
public struct DiningToken: Codable {
    public let value: String
    public let expiration: Int

    public var expirationDate: Date {
        Date().advanced(by: .init(expiration))
    }

    public enum CodingKeys: String, CodingKey {
        case value = "access_token"
        case expiration = "expires_in"
    }

}
