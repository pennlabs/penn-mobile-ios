//
//  Contact.swift
//  PennMobile
//
//  Created by Jordan Hochman on 11/16/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

public struct Contact: Identifiable, Sendable {
    public let name: String
    public let contactName: String
    public let phone: String
    public let description: String?
    public let phoneFiltered: String
    
    public var id: String { name }
    
    public init(name: String, contactName: String, phoneNumber: String, desc: String? = nil) {
        self.name = name
        self.phone = phoneNumber
        self.contactName = contactName
        self.description = desc
        self.phoneFiltered = phoneNumber.filter { $0.isNumber }
    }
}
