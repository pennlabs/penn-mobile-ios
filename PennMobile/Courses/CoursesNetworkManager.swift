//
//  CoursesNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 12/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

// MARK: - GET Courses
extension PennInTouchNetworkManager {
    fileprivate var courseURL: String {
        "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do?fastStart=mobileSchedule"
    }
    
    func getCourses(currentTermOnly: Bool = false, callback: @escaping ((_ result: Result<Set<Course>, NetworkingError>) -> Void)) {
        makeAuthRequest(targetUrl: courseURL, shibbolethUrl: shibbolethUrl) { (data, response, error) in
            self.makeAuthRequest(targetUrl: self.courseURL, shibbolethUrl: self.shibbolethUrl) { (data, response, error) in
                
                guard let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? else {
                    
                    if let error = error as? NetworkingError {
                        callback(.failure(error))
                    } else {
                        callback(.failure(.other))
                    }
                    return
                }
                
                do {
                    let terms = try self.parseTerms(from: html)
                    let selectedTerm = try self.parseSelectedTerm(from: html)

                    let courses = try self.parseCourses(from: html, term: selectedTerm)
                    if currentTermOnly {
                        let currentTerm = Course.currentTerm
                        if selectedTerm == currentTerm {
                            // If first term in list is the current term, return those courses
                            callback(.success(courses))
                        } else {
                            // Otherwise, we need to do another request but for just the current term
                            let remainingTerms = [currentTerm]
                            self.getCoursesHelper(terms: remainingTerms, courses: Set<Course>(), callback: { (courses) in
                                callback(.success(courses))
                            })
                        }
                    } else {
                        let remainingTerms = terms.filter { $0 != selectedTerm }
                        self.getCoursesHelper(terms: remainingTerms, courses: courses, callback: { (allCourses) in
                            callback(.success(allCourses))
                        })
                    }
                } catch {
                    callback(.failure(.parsingError))
                }
            }
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
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        task.resume()
    }
}

// MARK: - Course Parsing
extension PennInTouchNetworkManager {
    fileprivate func parseCourses(from html: String, term: String) throws -> Set<Course> {
        let doc: Document = try SwiftSoup.parse(html)
        guard let element: Element = (try doc.select("li").filter { $0.id() == "fullClassesDiv" }).first else {
            throw NetworkingError.parsingError
        }
        var subHtml = try element.html()
        subHtml.append("<")

        var courses = [Course]()

        let htmlSections = subHtml.getMatches(for: "(<b>[\\S\\s]*?(?:<br><br|<$))")
        for section in htmlSections {
            let startDates = section.getMatches(for: "<br> (.*?) -")
            let endDates = section.getMatches(for: "<br> .*? - (.*?) ")
            
            let instructors: [String] = section.getMatches(for: "Instructor\\(s\\): (.*?)\\s*<")
            let name = section.getMatches(for: "<b>(.*?)<\\/b> <br>")
            let code = section.getMatches(for: "\"><b>(.*?)<\\/b>")
            
            let meetingGroups = section.getMatches(for: "(<br>TBA |<br>[A-Z]+?&nbsp;.*?-.*?<\\/span>(?:.*?mobileSchedule\">.*?&nbsp; .*?&nbsp)?)")
            if name.count > 0 && code.count > 0 {
                var meetingTimes = [CourseMeetingTime]()
                var building: String? = nil
                var room: String? = nil
                var mainWeekdays = ""
                var startTime: String = ""
                var endTime: String = ""
                
                for group in meetingGroups {
                    let buildingCodes = group.getMatches(for: "mobileSchedule\">(.*?) <")
                    let rooms = group.getMatches(for: "&nbsp; (.*?)&")
                    let weekdaysArr = group.getMatches(for: "<br>([A-Z]+?)[& ]")
                    let startTimes = group.getMatches(for: "<br>\\S*?&nbsp;([\\d:]*?) <span class=\"ampm\">")
                    let endTimes = group.getMatches(for: "<\\/span> - (.*?) <")
                    let AMPMs = group.getMatches(for: "<span class=\"ampm\">(.*?)<")
                    
                    if buildingCodes.count > 0 && rooms.count > 0 {
                        building = buildingCodes[0]
                        room = rooms[0]
                    }
                    
                    var weekdays = ""
                    if weekdaysArr.count > 0 {
                        weekdays = weekdaysArr[0]
                    }
                    
                    if weekdays == "TBA" {
                        // Replace TBA with NA so app nor server thinks it occurs on Tuesday
                        weekdays = "NA"
                    }
                    
                    if mainWeekdays.isEmpty {
                        // If this is the first meeting group, set mainWeekdays to these weekdays
                        mainWeekdays = weekdays
                    }
                    
                    if startTimes.count > 0 && endTimes.count > 0 && AMPMs.count >= 2 {
                        startTime = "\(startTimes[0]) \(AMPMs[0])"
                        endTime = "\(endTimes[0]) \(AMPMs[1])"
                    }
                    
                    var weekdayArray = weekdays.getMatches(for: "([SMTWRF])")
                    if weekdayArray.isEmpty {
                        weekdayArray.append(weekdays)
                    }
                    
                    for weekday in weekdayArray {
                        let meetingTime = CourseMeetingTime(building: building, room: room, weekday: weekday, startTime: startTime, endTime: endTime)
                        meetingTimes.append(meetingTime)
                    }
                }
                
                if let mainMeeting = meetingTimes.first {
                    building = mainMeeting.building
                    room = mainMeeting.room
                    startTime = mainMeeting.startTime
                    endTime = mainMeeting.endTime
                }
                
                var startDate: String? = nil
                var endDate: String? = nil
                if let startStr = startDates.first, let endStr = endDates.first {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    if let sDate = formatter.date(from: startStr), let eDate = formatter.date(from: endStr) {
                        formatter.dateFormat = "yyyy-MM-dd"
                        startDate = formatter.string(from: sDate)
                        endDate = formatter.string(from: eDate)
                    }
                }
                
                let courseInstructors = instructors.first?.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
                let name = name[0].replacingOccurrences(of: "&amp;", with: "&")
                let fullCode = code[0].replacingOccurrences(of: " ", with: "")
                let codePieces = fullCode.split(separator: "-")
                let dept = String(codePieces[0])
                let code = String(codePieces[1])
                let section = String(codePieces[2])
                courses.append(Course(name: name, term: term, dept: dept, code: code, section: section, building: building, room: room, weekdays: mainWeekdays, startDate: startDate, endDate: endDate, startTime: startTime, endTime: endTime, instructors: courseInstructors, meetingTimes: meetingTimes))
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
