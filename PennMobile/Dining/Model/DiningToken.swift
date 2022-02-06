//
//  DiningToken.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 1/28/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
struct DiningToken: Codable {
    let value: String
    var expiration: Int {
        didSet {
            expirationDate = Date().advanced(by: .init(expiration))
        }
    }
    
    var expirationDate = Date()
    
    enum CodingKeys: String, CodingKey {
        case value = "access_token"
        case expiration = "expires_in"
    }
    
}
