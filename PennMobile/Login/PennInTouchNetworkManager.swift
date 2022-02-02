//
//  PennInTouchNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

class PennInTouchNetworkManager: NSObject, PennAuthRequestable {

    static let instance = PennInTouchNetworkManager()

    internal let baseURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    internal let degreeURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do?fastStart=mobileAdvisors"

    internal let shibbolethUrl = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do/Shibboleth.sso/SAML2/POST"
}

// MARK: - Degrees
extension PennInTouchNetworkManager {
    func getDegrees(callback: @escaping ((_ degrees: Set<Degree>?) -> Void)) {
        makeAuthRequest(targetUrl: degreeURL, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            let url = URL(string: self.degreeURL)!
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, response, _) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                            let degrees = try? self.parseDegrees(from: html)
                            callback(degrees)
                            return
                        }
                    }
                }
                callback(nil)
            }
            task.resume()
        }
    }
}

// MARK: - Degree Parsing
extension PennInTouchNetworkManager {
    fileprivate func parseDegrees(from html: String) throws -> Set<Degree> {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element: Element = try doc.getElementsByClass("data").first() else {
            throw NetworkingError.parsingError
        }
        let subElements = try element.select("li")
        var degrees = Set<Degree>()
        for element in subElements {
            let text = try element.text()
            guard let schoolStr = text.getMatches(for: "Division: (.*?)\\) ").first,
                let degreeStr = text.getMatches(for: "Degree: (.*?)\\)").first,
                let expectedGradTerm = text.getMatches(for: "Expected graduation term: (.*?\\d) ").first else {
                    throw NetworkingError.parsingError
            }
            var majors = Set<Major>()
            if let majorText = text.getMatches(for: "Major\\(s\\):(.*?)Expected graduation term").first?.split(separator: ":").first {
                let majorStr = String(majorText).getMatches(for: "\\d\\. (.*?)\\)")
                for str in majorStr {
                    if let nameCode = try? splitNameCode(str: str) {
                        majors.insert(Major(name: nameCode.name, code: nameCode.code))
                    }
                }
            }
            let schoolNameCode = try splitNameCode(str: schoolStr)
            let degreeNameCode = try splitNameCode(str: degreeStr)
            let degree = Degree(schoolName: schoolNameCode.name, schoolCode: schoolNameCode.code, degreeName: degreeNameCode.name, degreeCode: degreeNameCode.code, majors: majors, expectedGradTerm: expectedGradTerm)
            degrees.insert(degree)
        }
        return degrees
    }

    private func splitNameCode(str: String) throws -> (name: String, code: String) {
        let split = str.split(separator: "(")
        if split.count != 2 {
            throw NetworkingError.parsingError
        }
        let name = String(split[0].dropLast())
        let code = String(split[1])
        return (name, code)
    }
}

// MARK: - Basic Student Profile Parsing
extension PennInTouchNetworkManager {
//    fileprivate func parseStudent(from html: String) throws -> Account {
//        let namePattern = "white-space:nowrap; overflow:hidden; width: .*>\\s*(.*?)\\s*<\\/div>"
//        let fullName: String! = html.getMatches(for: namePattern).first
//
//        let photoPattern = "alt=\"User photo\" src=\"(.*?)\""
//        let encodedPhotoUrl = html.getMatches(for: photoPattern).first
//        let photoUrl: String! = encodedPhotoUrl?.replacingOccurrences(of: "&amp;", with: "&")
//
//        guard fullName != nil else {
//            throw NetworkingError.parsingError
//        }
//
//        let substrings = fullName.split(separator: ",")
//        var firstName: String
//        let lastName: String
//        if substrings.count < 2 {
//            firstName = fullName
//            lastName = fullName
//        } else {
//            firstName = String(substrings[1])
//            lastName = String(substrings[0])
//            firstName.removeFirst()
//        }
//
//        firstName = firstName.removingRegexMatches(pattern: " .$", replaceWith: "")
//
//        return Account(first: firstName, last: lastName, imageUrl: photoUrl)
//    }
}
