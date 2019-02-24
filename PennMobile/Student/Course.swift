//
//  Course.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class Course: Hashable {
    let name: String
    let term: String
    let code: String
    let section: String
    let instructors: [String]
    
    init(name: String, term: String, code: String, section: String, instructors: [String]) {
        self.name = name
        self.term = term
        self.code = code
        self.section = section
        self.instructors = instructors
    }
    
    var description: String {
        let instructorStr = instructors.joined(separator: ", ")
        return "\(term) \(code)-\(section) \(instructorStr)"
    }
    
    var hashValue: Int {
        return "\(term)\(code)\(section)".hashValue
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.term == rhs.term && lhs.code == rhs.code && lhs.section == rhs.section
    }
}
