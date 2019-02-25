//
//  StudentNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

class StudentNetworkManager: NSObject {
    
    static let instance = StudentNetworkManager()
    
    fileprivate let baseURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    fileprivate let degreeURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do?fastStart=mobileAdvisors"
    fileprivate let courseURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do?fastStart=mobileSchedule"
}

// MARK: - Student
extension StudentNetworkManager {
    func getStudent(request: URLRequest, cookies: [HTTPCookie], callback: @escaping ((_ student: Student?) -> Void)) {
        var mutableRequest: URLRequest = request
        let cookieStr = cookies.map {"\($0.name)=\($0.value);"}.joined()
        mutableRequest.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Set correct long-term cookie
                    let setCookieStr = httpResponse.allHeaderFields["Set-Cookie"] as? String
                    guard let sessionID: String = setCookieStr?.getMatches(for: "=(.*?);").first else {
                        callback(nil)
                        return
                    }
                    let newCookieStr = cookieStr.removingRegexMatches(pattern: "JSESSIONID=(.*?);", replaceWith: "JSESSIONID=\(sessionID);")
                    mutableRequest.url = URL(string: self.courseURL)
                    
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        if let student = try? self.parseStudent(from: html) {
                            self.getCoursesHelper(cookieStr: newCookieStr, callback: { (courses) in
                                student.courses = courses
                                callback(student)
                            })
                            return
                        }
                    }
                }
            }
            callback(nil)
        })
        task.resume()
    }
}

// MARK: - Degrees
extension StudentNetworkManager {
    func getDegrees(cookieStr: String, callback: @escaping ((_ degrees: Set<Degree>?) -> Void)) {
        let url = URL(string: degreeURL)!
        var request = URLRequest(url: url)
        request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
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
        })
        task.resume()
    }
}

// MARK: - Courses
extension StudentNetworkManager {
    func getCourses(request: URLRequest, cookies: [HTTPCookie], callback: @escaping ((_ courses: Set<Course>?) -> Void)) {
        var mutableRequest: URLRequest = request
        let cookieStr = cookies.map {"\($0.name)=\($0.value);"}.joined()
        mutableRequest.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let setCookieStr = httpResponse.allHeaderFields["Set-Cookie"] as? String
                    let sessionID: String = setCookieStr?.getMatches(for: "=(.*?);").first ?? ""
                    let newCookieStr = cookieStr.removingRegexMatches(pattern: "JSESSIONID=(.*?);", replaceWith: "JSESSIONID=\(sessionID);")
                    mutableRequest.url = URL(string: self.courseURL)
                    self.getCoursesHelper(cookieStr: newCookieStr, callback: callback)
                    return
                }
            }
            callback(nil)
        })
        task.resume()
    }
    
    fileprivate func getCoursesHelper(cookieStr: String, terms: [String]? = nil, courses: Set<Course>? = nil, callback: @escaping ((_ courses: Set<Course>?) -> Void)) {
        if terms != nil && terms!.isEmpty {
            callback(courses)
            return
        }
        
        let url = URL(string: terms == nil ? courseURL: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = terms == nil ? "GET" : "POST"
        request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        if let terms = terms {
            let params = [
                "fastStart": "mobileChangeStudentScheduleTermData",
                "term": terms[0],
                ]
            request.httpBody = params.stringFromHttpParameters().data(using: String.Encoding.utf8)
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        do {
                            var newTerms = terms
                            if terms == nil {
                                newTerms = try self.parseTerms(from: html)
                            }
                            
                            var newCourses: Set<Course>? = nil
                            if let currentTerm = newTerms?.first {
                                newCourses = try self.parseCourses(from: html, term: currentTerm)
                            }
                            
                            if let oldCourses = courses {
                                newCourses?.formUnion(oldCourses)
                            }
                            
                            newTerms = Array(newTerms?.dropFirst() ?? [])
                            self.getCoursesHelper(cookieStr: cookieStr, terms: newTerms, courses: newCourses, callback: callback)
                            return
                        } catch {
                        }
                    }
                }
            }
            callback(nil)
        })
        task.resume()
    }
}

// MARK: - Course Parsing
extension StudentNetworkManager {
    fileprivate func parseCourses(from html: String, term: String) throws -> Set<Course> {
        let doc: Document = try SwiftSoup.parse(html)
        let element: Element = try doc.select("li").filter { $0.id() == "fullClassesDiv" }.first!
        var subHtml = try element.html()
        subHtml.append("<") // For edge case where instructor is at EOF
        let instructors: [String] = subHtml.getMatches(for: "Instructor\\(s\\): (.*?)\\s*<")
        let nameCodes: [String] = try element.select("b").map { try $0.text() }
        var courses = [Course]()
        for i in 0..<instructors.count {
            let courseInstructors = instructors[i].split(separator: ",").map { String($0) }
            let name = nameCodes[2*i]
            let fullCode = nameCodes[2*i+1].replacingOccurrences(of: " ", with: "")
            let codePieces = fullCode.split(separator: "-")
            let courseCode = "\(codePieces[0])-\(codePieces[1])"
            let section = String(codePieces[2])
            courses.append(Course(name: name, term: term, code: courseCode, section: section, instructors: courseInstructors))
        }
        return Set(courses)
    }
    
    fileprivate func parseTerms(from html: String) throws -> [String] {
        let doc: Document = try SwiftSoup.parse(html)
        let terms: [String] = try doc.select("option").map { try $0.val() }
        return terms
    }
}

// MARK: - Degree Parsing
extension StudentNetworkManager {
    fileprivate func parseDegrees(from html: String) throws -> Set<Degree> {
        // TODO: complete parsing
        return Set<Degree>()
    }
}

// MARK: - Basic Student Profile Parsing
extension StudentNetworkManager {
    fileprivate func parseStudent(from html: String) throws -> Student {
        // TODO: complete parsing
        let namePattern = "white-space:nowrap; overflow:hidden; width: .*>\\s*(.*?)\\s*<\\/div>"
        let fullName: String! = html.getMatches(for: namePattern).first
        
        let photoPattern = "alt=\"User photo\" src=\"(.*?)\""
        let encodedPhotoUrl = html.getMatches(for: photoPattern).first
        let photoUrl: String! = encodedPhotoUrl?.replacingOccurrences(of: "&amp;", with: "&")
        
        guard fullName != nil && photoUrl != nil  else {
            throw NetworkingError.parsingError
        }
        
        let substrings = fullName.split(separator: " ")
        let firstName: String
        var lastName: String
        if substrings.count < 2 {
            firstName = fullName
            lastName = fullName
        } else {
            firstName = String(substrings[1])
            lastName = String(substrings[0])
            lastName.removeLast()
        }
        
        return Student(firstName: firstName, lastName: lastName, photoUrl: photoUrl, pennkey: "joshdo")
    }
}
