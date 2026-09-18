//
//  GSRShareCode.swift
//  PennMobile
//
//  Created by Khoi Dinh on 11/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct GSRShareCode: Codable, Sendable {
    public static let publicDeepLinkURL = "https://pennmobile.org/gsr/share"
    
    public let code: String
    
    public var link: String {
        "\(Self.publicDeepLinkURL)?data=\(code)"
    }
}
