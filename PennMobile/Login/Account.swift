//
//  Account.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class Account: Codable {
    var first: String?
    var last: String?
    var pennkey: String
    var pennid: Int
    var email: String?
    var imageUrl: String?
    var affiliations: [String]?
    
    var isStudent: Bool {
        return affiliations?.contains("student") ?? true
    }
    
    var degrees: Set<Degree>?
    var courses: Set<Course>?
    
    fileprivate static var account: Account?
    
    init(user: OAuthUser) {
        self.first = user.firstName
        self.last = user.lastName
        self.pennkey = user.username
        self.email = user.email
        self.pennid = user.pennid
        self.affiliations = user.affiliation
    }
    
    func isInWharton() -> Bool {
        return email?.contains("wharton") ?? false
    }
    
    func setEmail() {
        guard let degrees = degrees else { return }
        var potentialEmail: String? = nil
        for degree in degrees {
            switch degree.schoolCode {
            case "WH":
                email = "\(pennkey)@wharton.upenn.edu"
                return
            case "EAS":
                potentialEmail = "\(pennkey)@seas.upenn.edu"
            case "CAS", "SAS":
                potentialEmail = "\(pennkey)@sas.upenn.edu"
            case "NURS":
                potentialEmail = "\(pennkey)@nursing.upenn.edu"
            default:
                break
            }
        }
        email = potentialEmail
    }
    
    var description: String {
        var str = "\(first ?? "") \(last ?? "")"
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
    
    static func getAccount() -> Account? {
        if account == nil {
            account = UserDefaults.standard.getAccount()
        }
        return account
    }
    
    static func saveAccount(_ thisAccount: Account) {
        UserDefaults.standard.saveAccount(thisAccount)
        account = thisAccount
    }
    
    static func update(firstName: String? = nil, lastName: String? = nil, email: String? = nil) {
        guard let account = getAccount() else { return }
        if let firstName = firstName {
            account.first = firstName
        }
        if let lastName = lastName {
            account.last = lastName
        }
        if let email = email {
            account.email = email
        }
        saveAccount(account)
    }
    
    static func clear() {
        UserDefaults.standard.clearAccount()
        account = nil
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

// MARK: - Logged In
extension Account {
    static var isLoggedIn: Bool {
        OAuth2NetworkManager.instance.hasRefreshToken()
    }
}
