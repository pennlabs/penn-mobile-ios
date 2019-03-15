//
//  StudentNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

protocol CookieRequestable {}

extension CookieRequestable {
    func makeRequest(with req: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = req
        if let cookies = HTTPCookieStorage.shared.cookies {
            var cookieStr = cookies.map {"\($0.name)=\($0.value);"}.joined()
            cookieStr = cookieStr + "fastStartPage=fast.do;"
            request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
        }
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if let url = httpResponse.url, let allHeaderFields = httpResponse.allHeaderFields as? [String: String] {
                    let newCookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
                    for cookie in newCookies {
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                }
            }
            completionHandler(data, response, error)
        })
        task.resume()
    }
}

class StudentNetworkManager: NSObject, CookieRequestable {
    
    static let instance = StudentNetworkManager()
    
    fileprivate let baseURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    fileprivate let degreeURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do?fastStart=mobileAdvisors"
    fileprivate let courseURL = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do?fastStart=mobileSchedule"
}

// MARK: - Student
extension StudentNetworkManager {
    func getStudent(initialCallback: @escaping (_ student: Student?) -> Void, allCoursesCallback: @escaping (_ courses: Set<Course>?) -> Void) {
        let url = URL(string: baseURL)!
        let request = URLRequest(url: url)
        makeRequest(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        if let student = try? self.parseStudent(from: html) {
                            self.getCourses(currentTermOnly: true, callback: { (courses) in
                                student.courses = courses
                                self.getDegrees(callback: { (degrees) in
                                    student.degrees = degrees
                                    initialCallback(student)
                                    self.getCourses(currentTermOnly: false, callback: { (courses) in
                                        allCoursesCallback(courses)
                                    })
                                })
                            })
                            return
                        }
                    }
                }
            }
            initialCallback(nil)
        }
    }
}

// MARK: - Degrees
extension StudentNetworkManager {
    func getDegrees(callback: @escaping ((_ degrees: Set<Degree>?) -> Void)) {
        let url = URL(string: degreeURL)!
        let request = URLRequest(url: url)
        makeRequest(with: request) { (data, response, error) in
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
    }
}

// MARK: - Courses
extension StudentNetworkManager {
    fileprivate func getCourses(currentTermOnly: Bool = false, callback: @escaping ((_ courses: Set<Course>?) -> Void)) {
        let url = URL(string: courseURL)!
        let request = URLRequest(url: url)
        makeRequest(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        do {
                            let terms = try self.parseTerms(from: html)
                            let selectedTerm = try self.parseSelectedTerm(from: html)
                            
                            let courses = try self.parseCourses(from: html, term: selectedTerm)
                            if currentTermOnly {
                                let currentTerm = self.currentTerm()
                                if selectedTerm == currentTerm {
                                    // If first term in list is the current term, return those courses
                                    callback(courses)
                                } else {
                                    // Otherwise, we need to do another request but for just the current term
                                    let remainingTerms = [currentTerm]
                                    self.getCoursesHelper(terms: remainingTerms, courses: Set<Course>(), callback: { (courses) in
                                        callback(courses)
                                    })
                                }
                            } else {
                                let remainingTerms = terms.filter { $0 != selectedTerm }
                                self.getCoursesHelper(terms: remainingTerms, courses: courses, callback: { (allCourses) in
                                    callback(allCourses)
                                })
                            }
                            return
                        } catch {
                        }
                    }
                }
            }
            callback(nil)
        }
    }
    
    // Returns a set of courses for the provided terms unioned with the courses initially provided
    private func getCoursesHelper(terms: [String], courses: Set<Course>, callback: @escaping ((_ courses: Set<Course>) -> Void)) {
        if terms.isEmpty {
            callback(courses)
            return
        }

        let term = terms.first!
        let remainingTerms = terms.filter { $0 != term }
        
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let params = [
            "fastStart": "mobileChangeStudentScheduleTermData",
            "term": term,
            ]
        request.httpBody = params.stringFromHttpParameters().data(using: String.Encoding.utf8)
        
        makeRequest(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        if let subCourses: Set<Course> = try? self.parseCourses(from: html, term: term) {
                            let newCourses = courses.union(subCourses)
                            self.getCoursesHelper(terms: remainingTerms, courses: newCourses, callback: callback)
                            return
                        }
                    }
                }
            }
            callback(courses)
        }
    }
    
    private func currentTerm() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: now)
        formatter.dateFormat = "M"
        let month = Int(formatter.string(from: now))!
        let code: String
        if month <= 5 {
            code = "A"
        } else if month >= 8 {
            code = "C"
        } else {
            code = "B"
        }
        return "\(year)\(code)"
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
        subHtml.append("<")
        
        var courses = [Course]()

        let htmlSections = subHtml.getMatches(for: "br><br(.*?Instructor\\(s\\):.*?<)")
        for section in htmlSections {
            let buildingCodes = section.getMatches(for: "mobileSchedule\">(.*?) <")
            let rooms = section.getMatches(for: "&nbsp; (.*?)&")
            let weekdaysArr = section.getMatches(for: "<\\/span><\\/a> <br>(.*?)[& ]")
            let startTimes = section.getMatches(for: "<\\/span><\\/a> <br>.*?&nbsp;(.*?) <span class=\"ampm\">")
            let endTimes = section.getMatches(for: "<\\/span> - (.*?) <")
            let AMPMs = section.getMatches(for: "<span class=\"ampm\">(.*?)<")
            let startDates = section.getMatches(for: "<br> (.*?) -")
            let endDates = section.getMatches(for: "<br> .*? - (.*?) ")
            
            let instructors: [String] = section.getMatches(for: "Instructor\\(s\\): (.*?)\\s*<")
            let name = section.getMatches(for: "><b>(.*?)<\\/b> <br>")
            let code = section.getMatches(for: "\"><b>(.*?)<\\/b>")
            
            if name.count > 0 && code.count > 0 && instructors.count > 0 {
                var building: String? = nil
                var room: String? = nil
                if buildingCodes.count > 0 && rooms.count > 0 {
                    building = buildingCodes[0]
                    room = rooms[0]
                }
                
                var weekdays: String = ""
                if weekdaysArr.count > 0 {
                    weekdays = weekdaysArr[0]
                }
                
                var startTime: String = ""
                var endTime: String = ""
                if startTimes.count > 0 && endTimes.count > 0 && AMPMs.count == 2 {
                    startTime = "\(startTimes[0]) \(AMPMs[0])"
                    endTime = "\(endTimes[0]) \(AMPMs[1])"
                }
                
                var startDate = ""
                var endDate = ""
                if let startStr = startDates.first, let endStr = endDates.first {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    if let sDate = formatter.date(from: startStr), let eDate = formatter.date(from: endStr) {
                        formatter.dateFormat = "yyyy-MM-dd"
                        startDate = formatter.string(from: sDate)
                        endDate = formatter.string(from: eDate)
                    }
                }
                
                let courseInstructors = instructors[0].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                let name = name[0]
                let fullCode = code[0].replacingOccurrences(of: " ", with: "")
                let codePieces = fullCode.split(separator: "-")
                let dept = String(codePieces[0])
                let code = String(codePieces[1])
                let section = String(codePieces[2])
                courses.append(Course(name: name, term: term, dept: dept, code: code, section: section, building: building, room: room, weekdays: weekdays, startDate: startDate, endDate: endDate, startTime: startTime, endTime: endTime, instructors: courseInstructors))
            }
        }
        return Set(courses)
    }
    
    fileprivate func parseTerms(from html: String) throws -> [String] {
        let doc: Document = try SwiftSoup.parse(html)
        let terms: [String] = try doc.select("option").map { try $0.val() }
        return terms
    }
    
    fileprivate func parseSelectedTerm(from html: String) throws -> String {
        let doc: Document = try SwiftSoup.parse(html)
        let term = try doc.select("option[selected='selected']").map { try $0.val() }.first
        if term == nil {
            throw NetworkingError.parsingError
        }
        return term!
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
            guard let schoolStr = text.getMatches(for: "Division: (.*?)\\) ").first,
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
extension StudentNetworkManager {
    fileprivate func parseStudent(from html: String) throws -> Student {
        let namePattern = "white-space:nowrap; overflow:hidden; width: .*>\\s*(.*?)\\s*<\\/div>"
        let fullName: String! = html.getMatches(for: namePattern).first
        
        let photoPattern = "alt=\"User photo\" src=\"(.*?)\""
        let encodedPhotoUrl = html.getMatches(for: photoPattern).first
        let photoUrl: String! = encodedPhotoUrl?.replacingOccurrences(of: "&amp;", with: "&")
        
        guard fullName != nil else {
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
        
        return Student(first: firstName, last: lastName, imageUrl: photoUrl)
    }
}
