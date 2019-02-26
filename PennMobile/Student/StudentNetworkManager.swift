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
    fileprivate let reauthURL = "https://weblogin.pennkey.upenn.edu/login?factors=UPENN.EDU&cosign-pennkey-idp_reauth-0&https://idp.pennkey.upenn.edu/idp/Authn/ReauthRemoteUser?conversation=e1s1"
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
                            self.getCourses(cookieStr: newCookieStr, callback: { (courses) in
                                student.courses = courses
                                self.getDegrees(cookieStr: newCookieStr, callback: { (degrees) in
                                    student.degrees = degrees
                                    callback(student)
                                })
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
    
    func getStudent(request: URLRequest, cookies: [HTTPCookie], initialCallback: @escaping (_ student: Student?) -> Void, allCoursesCallback: @escaping (_ courses: Set<Course>?) -> Void) {
        var mutableRequest: URLRequest = request
        let cookieStr = cookies.map {"\($0.name)=\($0.value);"}.joined()
        mutableRequest.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: mutableRequest, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Set correct long-term cookie
                    let setCookieStr = httpResponse.allHeaderFields["Set-Cookie"] as? String
                    guard let sessionID: String = setCookieStr?.getMatches(for: "=(.*?);").first else {
                        initialCallback(nil)
                        return
                    }
                    let newCookieStr = cookieStr.removingRegexMatches(pattern: "JSESSIONID=(.*?);", replaceWith: "JSESSIONID=\(sessionID);")
                    mutableRequest.url = URL(string: self.courseURL)
                    
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        if let student = try? self.parseStudent(from: html) {
                            self.getCourses(cookieStr: newCookieStr, currentOnly: true, callback: { (courses) in
                                student.courses = courses
                                self.getPennKey(cookieStr: cookieStr, callback: { (pennkey) in
                                    student.pennkey = pennkey
                                    self.getDegrees(cookieStr: newCookieStr, callback: { (degrees) in
                                        student.degrees = degrees
                                        initialCallback(student)
                                        self.getCourses(cookieStr: newCookieStr, currentOnly: false, callback: { (courses) in
                                            allCoursesCallback(courses)
                                        })
                                    })
                                })
                            })
                            return
                        }
                    }
                }
            }
            initialCallback(nil)
        })
        task.resume()
    }
}

// MARK: - PennKey
/**
 * Note: WKWebview does not allow you to view HTTPBody (form data containing pennkey + password),
 *       so we must make a reauth request to get pennkey
 **/
extension StudentNetworkManager {
    func getPennKey(cookies: [HTTPCookie], callback: @escaping ((_ pennkey: String?) -> Void)) {
        let cookieStr = cookies.map {"\($0.name)=\($0.value);"}.joined()
        self.getPennKey(cookieStr: cookieStr, callback: callback)
    }
    
    fileprivate func getPennKey(cookieStr: String, callback: @escaping ((_ pennkey: String?) -> Void)) {
        let url = URL(string: reauthURL)!
        var request = URLRequest(url: url)
        request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        let pennkey = html.getMatches(for: "name=\"login\" value=\"(.*?)\"").first
                        callback(pennkey)
                        return
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
    fileprivate func getCourses(cookieStr: String, currentOnly: Bool = false, callback: @escaping ((_ courses: Set<Course>?) -> Void)) {
        let url = URL(string: courseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        do {
                            let terms = try self.parseTerms(from: html)
                            
                            if let currentTerm = terms.first {
                                let courses = try self.parseCourses(from: html, term: currentTerm)
                                if currentOnly {
                                    callback(courses)
                                } else {
                                    let remainingTerms = Array(terms.dropFirst())
                                    self.getCoursesHelper(cookieStr: cookieStr, terms: remainingTerms, courses: courses, callback: { (allCourses) in
                                        callback(allCourses)
                                    })
                                }
                            } else {
                                let emptySet = Set<Course>()
                                callback(emptySet)
                            }
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
    
    fileprivate func getCoursesHelper(cookieStr: String, terms: [String], courses: Set<Course>, callback: @escaping ((_ courses: Set<Course>) -> Void)) {
        if terms.isEmpty {
            callback(courses)
            return
        }

        let term = terms.first!
        let remainingTerms = Array(terms.dropFirst())
        
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        
        let params = [
            "fastStart": "mobileChangeStudentScheduleTermData",
            "term": term,
            ]
        request.httpBody = params.stringFromHttpParameters().data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        if let subCourses: Set<Course> = try? self.parseCourses(from: html, term: term) {
                            let newCourses = courses.union(subCourses)
                            self.getCoursesHelper(cookieStr: cookieStr, terms: remainingTerms, courses: newCourses, callback: callback)
                            return
                        }
                    }
                }
            }
            callback(courses)
        })
        task.resume()
        
    }
}

// MARK: - Course Parsing
extension StudentNetworkManager {
    fileprivate func parseCourses(from html: String, term: String) throws -> Set<Course> {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element: Element = (try doc.select("li").filter { $0.id() == "fullClassesDiv" }).first else {
            throw NetworkingError.parsingError
        }
        var subHtml = try element.html()
        subHtml.append("<") // For edge case where instructor is at EOF
        
        let buildingCodes = subHtml.getMatches(for: "mobileSchedule\">(.*?) <")
        let buildingIds = subHtml.getMatches(for: "BuildingId=(.*?)&amp;")
        let rooms = subHtml.getMatches(for: "&nbsp; (.*?)&")
        let daysOfWeekArr = subHtml.getMatches(for: "<\\/span><\\/a> <br>(.*?)&nbsp")
        let startTimes = subHtml.getMatches(for: "<\\/span><\\/a> <br>.*?&nbsp;(.*?) <span class=\"ampm\">")
        let endTimes = subHtml.getMatches(for: "<\\/span> - (.*?) <")
        let AMPMs = subHtml.getMatches(for: "<span class=\"ampm\">(.*?)<")
        
        let instructors: [String] = subHtml.getMatches(for: "Instructor\\(s\\): (.*?)\\s*<")
        let nameCodes: [String] = try element.select("b").map { try $0.text() }
        
        if buildingCodes.count != buildingIds.count && buildingIds.count != rooms.count
            && rooms.count >= instructors.count && nameCodes.count >= 2*instructors.count {
            throw NetworkingError.parsingError
        }
        
        var courses = [Course]()
        for i in 0..<instructors.count {
            var building: Building? = nil
            var room: String? = nil
            if i <= buildingCodes.count - 1 && i <= buildingIds.count - 1 && i <= rooms.count - 1 {
                if let buildingId = Int(buildingIds[i]) {
                    building = Building(code: buildingCodes[i], id: buildingId)
                    room = rooms[i]
                }
            }
            
            var daysOfWeek: String = ""
            var startTime: String = ""
            var endTime: String = ""
            if i <= daysOfWeekArr.count - 1 && i <= startTimes.count - 1 && i <= endTimes.count - 1 && 2*i <= AMPMs.count - 1 {
                daysOfWeek = daysOfWeekArr[i]
                startTime = "\(startTimes[i]) \(AMPMs[2*i])"
                endTime = "\(endTimes[i]) \(AMPMs[2*i+1])"
            }
            
            let courseInstructors = instructors[i].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            let name = nameCodes[2*i]
            let fullCode = nameCodes[2*i+1].replacingOccurrences(of: " ", with: "")
            let codePieces = fullCode.split(separator: "-")
            let courseCode = "\(codePieces[0])-\(codePieces[1])"
            let section = String(codePieces[2])
            courses.append(Course(name: name, term: term, code: courseCode, section: section, building: building, room: room, daysOfWeek: daysOfWeek, startTime: startTime, endTime: endTime, instructors: courseInstructors))
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
        let doc: Document = try SwiftSoup.parse(html)
        guard let element: Element = try doc.getElementsByClass("data").first() else {
            throw NetworkingError.parsingError
        }
        let subElements = try element.select("li")
        var degrees = Set<Degree>()
        for element in subElements {
            let text = try element.text()
            guard let divisionStr = text.getMatches(for: "Division: (.*?)\\) ").first,
                let degreeStr = text.getMatches(for: "Degree: (.*?)\\)").first,
                let expectedGradTerm = text.getMatches(for: "Expected graduation term: (.*?\\d) ").first else {
                    throw NetworkingError.parsingError
            }
            let majorStr = text.getMatches(for: "\\d\\. (.*?)\\)")
            var majors = Set<Major>()
            for str in majorStr {
                let nameCode = try splitNameCode(str: str)
                majors.insert(Major(name: nameCode.name, code: nameCode.code))
            }
            let divisionNameCode = try splitNameCode(str: divisionStr)
            let degreeNameCode = try splitNameCode(str: degreeStr)
            let degree = Degree(divisionName: divisionNameCode.name, divisionCode: divisionNameCode.code, degreeName: degreeNameCode.name, degreeCode: degreeNameCode.code, majors: majors, expectedGradTerm: expectedGradTerm)
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
        
        return Student(firstName: firstName, lastName: lastName, photoUrl: photoUrl)
    }
}
