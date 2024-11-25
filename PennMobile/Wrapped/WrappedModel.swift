//
//  WrappedData.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public struct WrappedModel: Codable {
    let semester: String
    let pages: [WrappedAPIUnit]
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.semester = try values.decode(String.self, forKey: .semester)
        let pagesRaw = try values.decode(SafeWrappedArray.self, forKey: .pages)
        if pagesRaw.elements.isEmpty {
            self.pages = []
        } else {
            self.pages = pagesRaw.elements
        }
    }
    
    public init(semester: String, pages: [WrappedAPIUnit]) {
        self.pages = pages
        self.semester = semester
    }
}

struct Empty: Decodable {}

struct SafeWrappedArray: Decodable {
    let elements: [WrappedAPIUnit]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var tempElements: [WrappedAPIUnit] = []
        

        while !container.isAtEnd {
            do {
                let element = try container.decode(WrappedAPIUnit.self)
                tempElements.append(element)
            } catch {
                // The decoder only advances elements on a successful call, so calling decodeNil advances the
                // decoder in the event that one is unsuccessful.
                _ = try? container.decode(Empty.self)
            }
        }
        self.elements = tempElements
    }
}
