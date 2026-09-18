//
//  WrappedModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

public struct WrappedModel: Decodable, Sendable {
    public let semester: String
    public var pages: [WrappedUnit]
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.semester = try values.decode(String.self, forKey: .semester)
        self.pages = try values.decodeIfPresent([WrappedUnit].self, forKey: .pages) ?? []
    }
    
    public init(semester: String, pages: [WrappedUnit]) {
        self.pages = pages
        self.semester = semester
    }
    
    enum CodingKeys: String, CodingKey {
        case pages, semester
    }
}
