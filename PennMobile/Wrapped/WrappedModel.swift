//
//  WrappedData.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public struct WrappedModel: Decodable {
    let semester: String
    // Designed to be optional for forwards compatability
    // (making pages an optional field was a design discussion for disabling wrapped between semesters)
    var pages: [WrappedUnit]
    
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
    
    mutating func loadModel() async {
        var newPages: [WrappedUnit] = await self.pages.asyncMap { page in
            var newPage = page
            await newPage.loadAnimation()
            return newPage
        }
        self.pages = newPages.filter({ $0.lottie != nil }).sorted(by: { $0.id < $1.id })
    }
}
