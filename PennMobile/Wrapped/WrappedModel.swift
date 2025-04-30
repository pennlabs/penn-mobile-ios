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
    // Designed to be optional for forwards compatability
    // (making pages an optional field was a design discussion for disabling wrapped between semesters)
    let pages: [WrappedAPIUnit]?
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.semester = try values.decode(String.self, forKey: .semester)
        let pagesRaw = try values.decodeIfPresent(SafeWrappedArray.self, forKey: .pages)
        guard let raw = pagesRaw else {
            self.pages = nil
            return
        }
        
        if raw.elements.isEmpty {
            self.pages = []
        } else {
            self.pages = raw.elements
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
