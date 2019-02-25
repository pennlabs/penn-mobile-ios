//
//  Degree.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class Degree: Hashable {
    let divisionName: String
    let divisionCode: String
    let degreeName: String
    let degreeCode: String
    let majors: Set<Major>
    let expectedGradTerm: String
    
    init(divisionName: String, divisionCode: String, degreeName: String, degreeCode: String, majors: Set<Major>, expectedGradTerm: String) {
        self.divisionName = divisionName
        self.divisionCode = divisionCode
        self.degreeName = degreeName
        self.degreeCode = degreeCode
        self.majors = majors
        self.expectedGradTerm = expectedGradTerm
    }
    
    var description: String {
        let majorStr = majors.map { $0.description }.joined(separator: "\n")
        return "\(divisionName) (\(divisionCode))\n\(degreeName) (\(degreeCode))\n\(majorStr)\n\(expectedGradTerm)"
    }
    
    var hashValue: Int {
        return description.hashValue
    }
    
    static func == (lhs: Degree, rhs: Degree) -> Bool {
        return lhs.divisionCode == rhs.divisionCode && lhs.degreeCode == rhs.degreeCode
            && lhs.expectedGradTerm == rhs.expectedGradTerm
            && lhs.majors.map { $0.hashValue }.reduce(0, +) == rhs.majors.map { $0.hashValue }.reduce(0, +)
    }
}

class Major: Hashable {
    let name: String
    let code: String
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
    
    var description: String {
        return "\(name) (\(code))"
    }
    
    var hashValue: Int {
        return "\(name)\(code)".hashValue
    }
    
    static func == (lhs: Major, rhs: Major) -> Bool {
        return lhs.name == rhs.name && lhs.code == rhs.code
    }
}
