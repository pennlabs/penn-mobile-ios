//
//  ShareCodeError.swift
//  PennMobile
//
//  Created by Khoi Dinh on 11/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

enum ShareCodeError: LocalizedError {
    case invalidShareCode
    case expiredShareCode
    case shareCodeNotFoundOrExpired
    case expiredGSR

    var errorDescription: String? {
        switch self {
        case .invalidShareCode:         
            return "Invalid share code."
        case .expiredShareCode:         
            return "This share code has expired."
        case .shareCodeNotFoundOrExpired: 
            return "Share code not found or expired."
        case .expiredGSR:               
            return "This GSR reservation has expired."
        }
    }
}
