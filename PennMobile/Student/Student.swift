//
//  Student.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class Student: NSObject {
    let firstName: String
    let lastName: String
    let pennkey: String
    
    var degrees: Set<Degree>?
    var courses: Set<Course>?
    
    init(firstName: String, lastName: String, pennkey: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.pennkey = pennkey
    }
}
