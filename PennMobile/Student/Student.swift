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
    let school: String
    let email: String
    
    var courses: Set<Course>?
    
    init(firstName: String, lastName: String, school: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.school = school
        self.email = email
    }
}
