//
//  SubletOfferData.swift
//  PennMobile
//
//  Created by Anthony Li on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

public struct SubletOfferData: Codable, Sendable {
    public var email: String
    public var phoneNumber: String
    public var message: String?
}
