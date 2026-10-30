//
//  Account.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

public struct Account: Codable, Hashable, Sendable {
    public let pennid: Int
    public let firstName: String?
    public let lastName: String?
    public let username: String
    public let email: String?
    public let student: Student
    public let groups: [String]
    public let emails: [Email]

    public var isStudent: Bool {
        groups.contains("student")
    }

    public var isInWharton: Bool {
        student.school.contains(where: { $0.id == 12 })
    }
}

public struct Student: Codable, Hashable, Sendable {
    public let major: [Major]
    public let school: [School]
    public let graduationYear: Int?
}

public struct Email: Codable, Hashable, Sendable {
    public let id: Int
    public let value: String
    public let primary: Bool
    public let verified: Bool
}

public struct School: Codable, Hashable, Sendable {
    public let id: Int
    public let name: String
}

public struct Major: Codable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let degreeType: String
}
