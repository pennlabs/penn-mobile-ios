//
//  Student.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class Account: Codable {
    var first: String
    var last: String
    var pennkey: String!
    var email: String?
    var imageUrl: String?
    var pennid: Int?
    
    var degrees: Set<Degree>?
    var courses: Set<Course>?
    
    fileprivate static var student: Account?
    
    init(first: String, last: String, imageUrl: String? = nil, pennkey: String? = nil, email: String? = nil, pennid: Int? = nil) {
        self.first = first
        self.last = last
        self.imageUrl = imageUrl
        self.pennkey = pennkey
        self.email = email
        self.pennid = pennid
    }
    
    func isInWharton() -> Bool {
        return email?.contains("wharton") ?? false
    }
    
    func setEmail() {
        guard let degrees = degrees, let pennkey = pennkey else { return }
        var potentialEmail: String? = nil
        for degree in degrees {
            switch degree.schoolCode {
            case "WH":
                email = "\(pennkey)@wharton.upenn.edu"
                return
            case "EAS":
                potentialEmail = "\(pennkey)@seas.upenn.edu"
                break
            case "CAS", "SAS":
                potentialEmail = "\(pennkey)@sas.upenn.edu"
                break
            case "NURS":
                potentialEmail = "\(pennkey)@nursing.upenn.edu"
                break
            default:
                break
            }
        }
        email = potentialEmail
    }
    
    var description: String {
        var str = "\(first) \(last)"
        if let imageUrl = imageUrl {
            str = "\(str)\n\(imageUrl)"
        }
        if let email = email {
            str = "\(str)\n\(email)"
        }
        if let degrees = degrees {
            for degree in degrees {
                str = "\(str)\n\(degree.description)"
            }
        }
        if let courses = courses {
            for course in courses {
                str = "\(str)\n\(course.description)"
            }
        }
        return str
    }
    
    static func getStudent() -> Account? {
        if student == nil {
            student = UserDefaults.standard.getStudent()
        }
        return student
    }
    
    static func saveStudent(_ thisStudent: Account) {
        UserDefaults.standard.saveStudent(thisStudent)
        student = thisStudent
    }
    
    static func update(firstName: String? = nil, lastName: String? = nil, email: String? = nil) {
        guard let student = getStudent() else { return }
        if let firstName = firstName {
            student.first = firstName
        }
        if let lastName = lastName {
            student.last = lastName
        }
        if let email = email {
            student.email = email
        }
        saveStudent(student)
    }
    
    static func clear() {
        UserDefaults.standard.clearStudent()
        student = nil
    }
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.first == rhs.first && lhs.last == rhs.last && lhs.imageUrl == rhs.imageUrl
                && lhs.pennkey == rhs.pennkey && lhs.email == rhs.email
    }
}

extension Account {
    func isFreshman() -> Bool {
        let now = Date()
        let components = Calendar.current.dateComponents([.year], from: now)
        let january = Calendar.current.date(from: components)!
        let june = january.add(months: 5)
        
        let year = components.year!
        let freshmanYear: Int
        if january <= now && now < june {
            freshmanYear = year + 3
        } else {
            freshmanYear = year + 4
        }
        
        if let degrees = degrees {
            for degree in degrees {
                // Check if in undergrad
                if ["WH", "EAS", "COL", "NUR"].contains(degree.schoolCode) {
                    if degree.expectedGradTerm == "Spring \(freshmanYear)" {
                        return true
                    }
                }
            }
        }
        return false
    }
}
