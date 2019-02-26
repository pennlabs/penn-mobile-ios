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
    let photoUrl: String
    
    var pennkey: String!
    var degrees: Set<Degree>?
    var courses: Set<Course>?
    
    var preferredEmail: String?
    
    init(firstName: String, lastName: String, photoUrl: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.photoUrl = photoUrl
    }
    
    func getPotentialEmail() -> String? {
        guard let degrees = degrees, let pennkey = pennkey else { return nil }
        var potentialEmail: String? = nil
        for degree in degrees {
            switch degree.divisionCode {
            case "WH":
                return "\(pennkey)@wharton.upenn.edu"
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
        return potentialEmail
    }
    
    override var description: String {
        var str = "\(firstName) \(lastName) \(photoUrl)"
        if let email = getPotentialEmail() {
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
}
