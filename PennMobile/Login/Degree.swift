//
//  Degree.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct Degree: Codable, Hashable {
    let schoolName: String
    let schoolCode: String
    let degreeName: String
    let degreeCode: String
    let majors: Set<Major>
    let expectedGradTerm: String

    var description: String {
        let majorStr = majors.map { $0.name }.joined(separator: "\n")
        return "\(schoolName) (\(schoolCode))\n\(degreeName) (\(degreeCode))\n\(majorStr)\n\(expectedGradTerm)"
    }
}

//struct Major: Codable, Hashable {
//    let name: String
//    let code: String
//
//    enum CodingKeys: String, CodingKey {
//        case name = "major_name"
//        case code = "major_code"
//    }
//
//    var description: String {
//        return "\(name) (\(code))"
//    }
//}
