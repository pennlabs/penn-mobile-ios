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
    func getStudent(callback: @escaping (_ student: Student?) -> Void) {
        let url = URL(string: baseURL)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data, let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                        if let student = try? self.parseStudent(from: html) {
                            self.getCourses(currentTermOnly: true, callback: { (courses) in
                                student.courses = courses
                                self.getDegrees(callback: { (degrees) in
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
        }
        task.resume()
    }
}

// MARK: - Degrees
extension StudentNetworkManager {
    func getDegrees(callback: @escaping ((_ degrees: Set<Degree>?) -> Void)) {
        let url = URL(string: degreeURL)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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

// MARK: - Courses
extension StudentNetworkManager {
    func getCourses(currentTermOnly: Bool = false, callback: @escaping ((_ courses: Set<Course>?) -> Void)) {
        let url = URL(string: courseURL)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        task.resume()
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

        let htmlSections = subHtml.getMatches(for: "br><br(.*?Instructor\\(s\\):[\\S\\s]*?<)")
        for section in htmlSections {
            let startDates = section.getMatches(for: "<br> (.*?) -")
            let endDates = section.getMatches(for: "<br> .*? - (.*?) ")
            
            let instructors: [String] = section.getMatches(for: "Instructor\\(s\\): (.*?)\\s*<")
            let name = section.getMatches(for: "><b>(.*?)<\\/b> <br>")
            let code = section.getMatches(for: "\"><b>(.*?)<\\/b>")
            
            let meetingGroups = section.getMatches(for: "(<br>TBA |<br>[A-Z]+?&nbsp;.*?-.*?<\\/span>(?:.*?mobileSchedule\">.*?&nbsp; .*?&nbsp)?)")
            if name.count > 0 && code.count > 0 && instructors.count > 0 {
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
        
        let substrings = fullName.split(separator: ",")
        var firstName: String
        let lastName: String
        if substrings.count < 2 {
            firstName = fullName
            lastName = fullName
        } else {
            firstName = String(substrings[1])
            lastName = String(substrings[0])
            firstName.removeFirst()
        }
        
        firstName = firstName.removingRegexMatches(pattern: " .$", replaceWith: "")
        
        return Student(first: firstName, last: lastName, imageUrl: photoUrl)
    }
    
    var martaHTML: String {
        get {
            return """
            <?xml version="1.0" encoding="iso-8859-1"?>
            <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
            
            <html>
            <!-- meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" /  -->
            <!-- $Id: mobileCommonTop.jsp,v 1.1 2010/12/09 21:10:22 harveycg Exp $ -->
            
            <!-- $Id: mobileStudentSchedule.jsp,v 1.23 2013/08/14 16:28:26 harveycg Exp $ -->
            
            
            <head>
            <script type="text/javascript" src="../assets/mobile/pennInTouchMobile.js?v=2.1.372"></script>
            <script type="text/javascript" src="../fast/jq.js?v=2.1.372"></script>
            <script type="text/javascript" src="../fast/fastFrame.js?v=2.1.372"></script>
            <script type="text/javascript">
            fastAllAlertsModal = true;
            </script>
            <script type="text/javascript" src="../fast/jqueryui/js/jquery-ui-1.8.16.custom.min.js?v=2.1.372"></script>
            <script type="text/javascript" src="../fast/jquery.blockUI.js?v=2.1.372"></script>
            <script type="text/javascript">
            $().ajaxStop($.unblockUI);
            $.blockUI.defaults.message = '<img src="../fast/images/busy.gif" alt="busy"/>';
            $.blockUI.defaults.css.border = 'none';
            $.blockUI.defaults.css.backgroundColor = 'transparent';
            $.blockUI.defaults.overlayCSS.opacity = '0.02';
            $.blockUI.defaults.fadeIn = '200';
            $.blockUI.defaults.fadeOut = '400';
            $.blockUI.defaults.baseZ = 2000;
            $.blockUI.defaults.timeout = '120000';
            fastThrobberTimeoutMillis = 120000;
            fastConsoleLogBlocking = false;
            fastDontUseVariableBlockingJs = false;
            </script>
            <script type="text/javascript" src="../fast/dhtmlx/dhtmlxTabbar/dhtmlxtabbar_start.js?v=2.1.372"></script>
            <link  type="text/css" href="../fast/dhtmlx/dhtmlxCombo/dhtmlxcombo.css?v=2.1.372" rel="stylesheet"/>
            <link  type="text/css" href="../fast/dhtmlx/dhtmlxTabbar/dhtmlxtabbar.css?v=2.1.372" rel="stylesheet"/>
            <link  type="text/css" href="../fast/dhtmlx/dhtmlxMenu/skins/dhtmlxmenu_dhx_blue.css?v=2.1.372" rel="stylesheet"/>
            <link  type="text/css" href="../fast/jqueryui/css/custom-theme/jquery-ui-1.8.16.custom.css?v=2.1.372" rel="stylesheet"/>
            <link  type="text/css" href="../assets/mobile/iphone.css?v=2.1.372" rel="stylesheet"/>
            <link  type="text/css" href="../assets/mobile/mobile.css?v=2.1.372" rel="stylesheet"/>
            <!--
            SERVER NAME: fastprod-large-a-07, realm name: null
            -->
            <script type="text/javascript">
            fastInactivityTimeoutIntervalMinutes  = 10;
            </script>
            <script type="text/javascript">
            fastAlreadySubmitted=false;
            </script>
            
            <script type="text/javascript">
            checkToSeeIfUserWantsToKeepSessionTimeout = (1000*60*10)-1000*60*1;
            sessionTimeoutUserQuestionWindowUrl = '../fast/fastEndSessionQuestion.htm';
            sessionTimedOutUrl = 'https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast.do?fastSessionInactive=true';
            startPageForCookie = 'fast.do?fastStart=mobile';
            setSessionLengthTimeouts();
            </script>
            
            
            <!-- $Id: mobileCommonHead.jsp,v 1.1 2010/12/09 21:10:22 harveycg Exp $ -->
            <meta http-equiv="Content-Type" content="text/html" />
            <meta name="HandheldFriendly" content="True"/>
            <meta name="viewport" content="width=device-width, height=device-height, user-scalable=yes, minimum-scale=.5"/>
            
            <title>Course schedule</title>
            
            </head>
            
            
            
            
            <!-- $Id: mobileCommonBodyTag.jsp,v 1.1 2010/12/09 21:10:22 harveycg Exp $ -->
            
            
            <body>
            
            
            <noscript>
            <center><b><font color="red">
            Javascript has been disabled in your browser. You must enable javascript in order to utilize this application.
            </font></b></center>
            </noscript>
            
            
            
            
            
            
            
            
            <div id="header">
            
            
            <a href="/pennInTouch/jsp/fast2.do?fastStart=mobile" class="nav">
            Home
            </a>
            
            
            
            
            
            
            
            
            
            <h1>
            
            <img src="../assets/images/pennLogoCenter.png" align="middle" height="23" style="margin-top:2px;" alt="UPenn logo"/>
            
            </h1>
            
            <a id="backButton" class="nav Action" href="/pennInTouch/jsp/fast2.do?fastStart=mobile">
            Back
            </a>
            
            
            
            
            
            </div>
            
            
            <div class="errorMessageDiv">
            
            
            
            
            
            </div>
            
            
            
            <ul id="statusFrame" style="display:none">
            <li>
            <span style="font-size: 25px; color: red; font-weight: bold">ATTENTION:</span>
            <span id="statusFrameInner" style="color: red; font-weight: bold;">&nbsp;</span>
            </li>
            </ul>
            
            <script type="text/javascript">
            updateStatus();
            window.setInterval('updateStatus()', 60*1000);
            </script>
            
            
            
            
            
            
            
            
            <ul>
            <li class="arrow info" id="studentScheduleDivControlDiv">
            <a href="javascript:void(0);" onclick="toggleALayer('studentScheduleDivControlDiv', 'studentScheduleDiv', 'arrow info', 'arrow infoDown');">
            <b>Course schedule</b>
            </a>
            </li>
            <li id="studentScheduleDiv" style=" display:none; ">
            This page provides a view of your daily schedule and/or weekly schedule where appropriate and your schedule for a given term.
            </li>
            </ul>
            
            
            
            
            
            <script>
            function closeCourseDetailsMobile(){
            var detailsDiv = document.getElementById("courseDetailsDivAjaxMobileDiv");
            detailsDiv.style.display = "none";
            scroll(0,0);
            }
            
            function openCourseDetailsMobile(){
            var detailsDiv = document.getElementById("courseDetailsDivAjaxMobileDiv");
            detailsDiv.style.display = "block";
            $('#courseDetailsDivAjaxMobileDiv').height($(document).height());
            scroll(0,0);
            return true;
            }
            </script>
            
            <div id="courseDetailsDivAjaxMobileDiv" style="display:none; margin:0 0 0 0; position:absolute; top:0; left:0; width:100%; background-color: white; ">
            <div style="padding-left:5px;">
            <ul id="courseDetailsDivAjaxMobileUl">
            <li id="courseDetailsDivAjaxMobileLi">
            </li>
            <li id="courseDetailsDivAjaxMobileP" class="buttonLi">
            <a href="javascript:void(0);" onclick="closeCourseDetailsMobile();" class="button white innerButton">
            Close course details
            </a>
            </li>
            </ul>
            </div>
            </div>
            
            
            
            <ul class="form">
            <li>
            <form id="changeTerm1" method="post" action="fast2.do">
            <input type="hidden" name="fastStart" value="mobileChangeStudentScheduleTermData" />
            
            <label for="term">Schedule for:</label>
            
            <select id="T2XUSX0M" name="term" onchange="return fastElementChange(event, null, null, 'changeTerm1', false, null, 'term', 'onchange', false, false, this);" class="fastFormField" ><option value="2019C" >Fall 2019</option>
            <option value="2019A"  selected="selected">Spring 2019</option>
            <option value="2018C" >Fall 2018</option>
            </select>
            </form>
            </li>
            </ul>
            
            
            <ul>
            <li>
            <b>Classes today</b>
            </li>
            <li id="dailyClassesDiv">
            
            
            
            
            
            You have no classes today.
            
            
            
            
            
            </li>
            </ul>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <ul>
            <li class="arrow info" id="weeklyClassesControlDiv">
            <a href="javascript:void(0);" onclick="toggleALayer('weeklyClassesControlDiv', 'weeklyClassesDiv', 'arrow info', 'arrow infoDown');">
            <b>Classes this week</b>
            </a>
            </li>
            <li id="weeklyClassesDiv" style=" display:none; ">
            
            
            
            
            
            <b>Principles II</b>
            <br/>
            
            
            
            
            
            <b>PHYS-151-003</b>
            
            
            
            
            
            
            
            M&nbsp;10:00 <span class="ampm">AM</span> - 11:00 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;A8
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Bo Zhen
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1435757">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Calculus III</b>
            <br/>
            
            
            
            
            
            <b>MATH-240-002</b>
            
            
            
            
            
            
            
            M&nbsp;1:00 <span class="ampm">PM</span> - 2:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;A1
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Leandro A Lichtenfelz
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441359">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Programming Languages and Techniques II</b>
            <br/>
            
            
            
            
            
            <b>CIS -121-203</b>
            
            
            
            
            
            
            
            M&nbsp;2:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1141&backLink=fastStart=mobileSchedule">
            MOOR
            </a>
            &nbsp;100B
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Luigi N Mangione, Satya Prafful Tangirala
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1436381">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Automata,Comput.& Complx</b>
            <br/>
            
            
            
            
            
            <b>CIS -262-001</b>
            
            
            
            
            
            
            
            M&nbsp;3:00 <span class="ampm">PM</span> - 4:30 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1146&backLink=fastStart=mobileSchedule">
            MEYH
            </a>
            &nbsp;B1
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Aaron L Roth
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><br/>
            
            
            
            
            <b>Automata, Computability, and Complexity</b>
            <br/>
            
            
            
            
            
            <b>CIS -262-201</b>
            
            
            
            
            
            
            
            M&nbsp;4:30 <span class="ampm">PM</span> - 5:30 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1140&backLink=fastStart=mobileSchedule">
            LEVH
            </a>
            &nbsp;101
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Aaron L Roth
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><br/>
            
            
            
            
            <b>Prog Lang and Tech II</b>
            <br/>
            
            
            
            
            
            <b>CIS -121-001</b>
            
            
            
            
            
            
            
            T&nbsp;9:00 <span class="ampm">AM</span> - 10:30 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1143&backLink=fastStart=mobileSchedule">
            TOWN
            </a>
            &nbsp;100
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Rajiv Gandhi
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1436381">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Cinema and Media: Global Film Theory</b>
            <br/>
            
            
            
            
            
            <b>ARTH-295-401</b>
            
            
            
            
            
            
            
            T&nbsp;10:30 <span class="ampm">AM</span> - 11:30 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1158&backLink=fastStart=mobileSchedule">
            BENN
            </a>
            &nbsp;401
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Meta Mazaj, Karen Redrobe
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1437844">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Principles of Physics II: Electromagnetism and Radiation</b>
            <br/>
            
            
            
            
            
            <b>PHYS-151-136</b>
            
            
            
            
            
            
            
            T&nbsp;1:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;4C6
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Clay Snowden Miranda Contee
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441215">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Principles II</b>
            <br/>
            
            
            
            
            
            <b>PHYS-151-003</b>
            
            
            
            
            
            
            
            W&nbsp;10:00 <span class="ampm">AM</span> - 11:00 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;A8
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Bo Zhen
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1435757">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Calculus III</b>
            <br/>
            
            
            
            
            
            <b>MATH-240-002</b>
            
            
            
            
            
            
            
            W&nbsp;1:00 <span class="ampm">PM</span> - 2:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;A1
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Leandro A Lichtenfelz
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441359">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Principles II</b>
            <br/>
            
            
            
            
            
            <b>PHYS-151-003</b>
            
            
            
            
            
            
            
            W&nbsp;2:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;A8
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Bo Zhen
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1435757">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Automata,Comput.& Complx</b>
            <br/>
            
            
            
            
            
            <b>CIS -262-001</b>
            
            
            
            
            
            
            
            W&nbsp;3:00 <span class="ampm">PM</span> - 4:30 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1146&backLink=fastStart=mobileSchedule">
            MEYH
            </a>
            &nbsp;B1
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Aaron L Roth
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><br/>
            
            
            
            
            <b>Calculus III</b>
            <br/>
            
            
            
            
            
            <b>MATH-240-213</b>
            
            
            
            
            
            
            
            R&nbsp;8:00 <span class="ampm">AM</span> - 9:00 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;4C4
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Sammy Sbiti
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441582">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Prog Lang and Tech II</b>
            <br/>
            
            
            
            
            
            <b>CIS -121-001</b>
            
            
            
            
            
            
            
            R&nbsp;9:00 <span class="ampm">AM</span> - 10:30 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1143&backLink=fastStart=mobileSchedule">
            TOWN
            </a>
            &nbsp;100
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Rajiv Gandhi
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1436381">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Cinema and Media: Global Film Theory</b>
            <br/>
            
            
            
            
            
            <b>ARTH-295-401</b>
            
            
            
            
            
            
            
            R&nbsp;10:30 <span class="ampm">AM</span> - 11:30 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1158&backLink=fastStart=mobileSchedule">
            BENN
            </a>
            &nbsp;401
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Meta Mazaj, Karen Redrobe
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1437844">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Cinema and Media</b>
            <br/>
            
            
            
            
            
            <b>ARTH-295-405</b>
            
            
            
            
            
            
            
            R&nbsp;2:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1158&backLink=fastStart=mobileSchedule">
            BENN
            </a>
            &nbsp;138
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Helen Rachel Stuhr-Rommereim
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><br/>
            
            
            
            
            <b>Principles II</b>
            <br/>
            
            
            
            
            
            <b>PHYS-151-003</b>
            
            
            
            
            
            
            
            R&nbsp;5:00 <span class="ampm">PM</span> - 6:00 <span class="ampm">PM</span>
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Bo Zhen
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1435757">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Principles II</b>
            <br/>
            
            
            
            
            
            <b>PHYS-151-003</b>
            
            
            
            
            
            
            
            F&nbsp;10:00 <span class="ampm">AM</span> - 11:00 <span class="ampm">AM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;A8
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Bo Zhen
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1435757">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            
            
            <b>Calculus III</b>
            <br/>
            
            
            
            
            
            <b>MATH-240-002</b>
            
            
            
            
            
            
            
            F&nbsp;1:00 <span class="ampm">PM</span> - 2:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/>
            <a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">
            DRLB
            </a>
            &nbsp;A1
            
            &nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Leandro A Lichtenfelz
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441359">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            <br/><br/>
            
            
            </li>
            </ul>
            
            
            
            
            
            
            
            
            
            
            
            <ul>
            <li id="fullClassesDivControl" class="arrow info">
            <a href="javascript:void(0);" onclick="toggleALayer('fullClassesDivControl', 'fullClassesDiv', 'arrow info', 'arrow infoDown');">
            <b>Full schedule</b>
            </a>
            </li>
            
            <li id="fullClassesDiv" style=" display:none; ">
            
            
            
            
            
            <br/><br/><b>Cinema and Media: Global Film Theory</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX0O','','T2XUSX0O',false);" style="display:inline;" id="T2XUSX0O_text"><span class="fastButtonLinkText"><b>ARTH-295-401</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>TR&nbsp;10:30 <span class="ampm">AM</span> - 11:30 <span class="ampm">AM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1158&backLink=fastStart=mobileSchedule">BENN
            </a>
            &nbsp; 401&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Meta Mazaj, Karen Redrobe
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1437844">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            
            <br/><br/><b>Cinema and Media</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX0Q','','T2XUSX0Q',false);" style="display:inline;" id="T2XUSX0Q_text"><span class="fastButtonLinkText"><b>ARTH-295-405</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>R&nbsp;2:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1158&backLink=fastStart=mobileSchedule">BENN
            </a>
            &nbsp; 138&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Helen Rachel Stuhr-Rommereim
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><br/><b>Prog Lang and Tech II</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX0S','','T2XUSX0S',false);" style="display:inline;" id="T2XUSX0S_text"><span class="fastButtonLinkText"><b>CIS -121-001</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>TR&nbsp;9:00 <span class="ampm">AM</span> - 10:30 <span class="ampm">AM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1143&backLink=fastStart=mobileSchedule">TOWN
            </a>
            &nbsp; 100&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Rajiv Gandhi
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1436381">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            
            <br/><br/><b>Programming Languages and Techniques II</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX0U','','T2XUSX0U',false);" style="display:inline;" id="T2XUSX0U_text"><span class="fastButtonLinkText"><b>CIS -121-203</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>M&nbsp;2:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1141&backLink=fastStart=mobileSchedule">MOOR
            </a>
            &nbsp; 100B&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Luigi N Mangione, Satya Prafful Tangirala
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1436381">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            
            <br/><br/><b>Automata,Comput.& Complx</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX0W','','T2XUSX0W',false);" style="display:inline;" id="T2XUSX0W_text"><span class="fastButtonLinkText"><b>CIS -262-001</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>MW&nbsp;3:00 <span class="ampm">PM</span> - 4:30 <span class="ampm">PM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1146&backLink=fastStart=mobileSchedule">MEYH
            </a>
            &nbsp; B1&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Aaron L Roth
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><br/><b>Automata, Computability, and Complexity</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX0Y','','T2XUSX0Y',false);" style="display:inline;" id="T2XUSX0Y_text"><span class="fastButtonLinkText"><b>CIS -262-201</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>M&nbsp;4:30 <span class="ampm">PM</span> - 5:30 <span class="ampm">PM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1140&backLink=fastStart=mobileSchedule">LEVH
            </a>
            &nbsp; 101&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Aaron L Roth
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><br/><b>Calculus III</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX00','','T2XUSX00',false);" style="display:inline;" id="T2XUSX00_text"><span class="fastButtonLinkText"><b>MATH-240-002</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>MWF&nbsp;1:00 <span class="ampm">PM</span> - 2:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">DRLB
            </a>
            &nbsp; A1&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Leandro A Lichtenfelz
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441359">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            
            <br/><br/><b>Calculus III</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX02','','T2XUSX02',false);" style="display:inline;" id="T2XUSX02_text"><span class="fastButtonLinkText"><b>MATH-240-213</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>R&nbsp;8:00 <span class="ampm">AM</span> - 9:00 <span class="ampm">AM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">DRLB
            </a>
            &nbsp; 4C4&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Sammy Sbiti
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441582">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            
            <br/><br/><b>Principles II</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX04','','T2XUSX04',false);" style="display:inline;" id="T2XUSX04_text"><span class="fastButtonLinkText"><b>PHYS-151-003</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>MWF&nbsp;10:00 <span class="ampm">AM</span> - 11:00 <span class="ampm">AM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">DRLB
            </a>
            &nbsp; A8&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            <br/>W&nbsp;2:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">DRLB
            </a>
            &nbsp; A8&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            <br/>R&nbsp;5:00 <span class="ampm">PM</span> - 6:00 <span class="ampm">PM</span>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Bo Zhen
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1435757">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            
            <br/><br/><b>Principles of Physics II: Electromagnetism and Radiation</b>
            
            
            
            
            <br/><a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX06','','T2XUSX06',false);" style="display:inline;" id="T2XUSX06_text"><span class="fastButtonLinkText"><b>PHYS-151-136</b></span></a>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>T&nbsp;1:00 <span class="ampm">PM</span> - 3:00 <span class="ampm">PM</span>
            
            
            
            
            
            <br/><a style="display:inline;" href="/pennInTouch/jsp/fast2.do?fastStart=mobileBuildingLocation&currentCourseBuildingId=1134&backLink=fastStart=mobileSchedule">DRLB
            </a>
            &nbsp; 4C6&nbsp;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <br/>
            01/16/2019
            - 05/01/2019
            
            
            
            
            
            
            
            
            <br/>Instructor(s): Clay Snowden Miranda Contee
            
            
            
            
            
            
            
            
            
            
            
            
            <br/><a target="_new" href="https://upenn.instructure.com/courses/1441215">Link&nbsp;<img src="../assets/images/externalLink.gif" align="top" width="14" height="14" border="0"></a>
            
            
            
            
            
            
            
            
            </li>
            </ul>
            
            
            
            
            
            
            
            
            
            
            
            
            <ul>
            <li id="fullClassesScheduleDivControl" class="arrow info">
            <a href="javascript:void(0);" onclick="toggleALayer('fullClassesScheduleDivControl', 'fullClassesScheduleDiv', 'arrow info', 'arrow infoDown');">
            <b>Visual schedule</b>
            </a>
            </li>
            
            
            
            <li id="fullClassesScheduleDiv" style="padding-left:0px;  display:none; ">
            <img  height="180.21201413427562" src="fast.png?fastWebService=image&amp;id=T2XUSX08" border="0" width="300"  />
            
            <br/>&nbsp;<a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX09','fastSameTarget','T2XUSX09',false);" style="display:inline;" id="T2XUSX09_text"><span class="fastButtonLinkText">Save image</span></a>
            
            </li>
            
            
            
            
            </ul>
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            <form name="bandnform" action="https://secure.bncollege.com/webapp/wcs/stores/servlet/TBListView?" method="post" target="_bAndNWindow">
            <input type="hidden" name="catalogId" value="10001"/>
            <input type="hidden" name="storeId" value="10056"/>
            <input type="hidden" name="courseXml" value='<?xml version="1.0" encoding="UTF-8"?><textbookorder><courses><course dept="ARTH" num="295" sect="401" term="W19" /><course dept="ARTH" num="295" sect="405" term="W19" /><course dept="CIS" num="121" sect="001" term="W19" /><course dept="CIS" num="121" sect="203" term="W19" /><course dept="CIS" num="262" sect="001" term="W19" /><course dept="CIS" num="262" sect="201" term="W19" /><course dept="MATH" num="240" sect="002" term="W19" /><course dept="MATH" num="240" sect="213" term="W19" /><course dept="PHYS" num="151" sect="003" term="W19" /><course dept="PHYS" num="151" sect="136" term="W19" /></courses></textbookorder>'/>
            <p/><a href="javascript:void(0);" class="button white" onclick="document.bandnform.submit();return false;">Order textbooks</a></p>
            
            </form>
            
            
            
            
            
            
            <ul class="data">
            <li>
            &copy; 2019, <a href="http://m.upenn.edu" target="_blank">University of Pennsylvania</a> &nbsp;||&nbsp;
            <a href="http://www.upenn.edu/privacy/" target="_blank">Privacy</a> &nbsp;||&nbsp;
            
            
            
            <a href="#" onclick="return fastGoToUrl(event, 'fast2.do?fastButtonId=T2XUSX1A','','T2XUSX1A',false);" title="End your session with this application" class="fastWhitelinkButton" id="T2XUSX1A_text"><span class="fastButtonLinkText" title="End your session with this application">Log out</span></a>
            &nbsp;||&nbsp;
            
            
            
            <a href="/pennInTouch/jsp/fast2.do?fastStart=fullSite">
            Full site
            </a>
            
            </li>
            </ul>
            
            <!-- $Id: mobileCommonPageEnd.jsp,v 1.10 2011/03/08 21:27:15 harveycg Exp $ -->
            
            <!-- $Id: mobileCommonBottom.jsp,v 1.3 2011/02/07 13:49:07 harveycg Exp $ -->
            
            
            
            <script type="text/javascript">
            
            $.blockUI.defaults.message = "<img src='../fast/images/busy.gif' alt='busy'/>";
            $.blockUI.defaults.css.border = 'none';
            $.blockUI.defaults.css.backgroundColor = 'transparent';
            $.blockUI.defaults.overlayCSS.opacity = '0.02';
            $.blockUI.defaults.fadeIn = '200';
            $.blockUI.defaults.fadeOut = '400';
            $.blockUI.defaults.timeout = '30000';
            
            $().ajaxStop($.unblockUI);
            
            
            </script>
            <script type="text/javascript">
            var fastResponseJsTemp = {"FastResponseJs":{"disableGoogleAutoFill":true,"controller":"fast2.do","fieldTypesToCopy":{"AjaxMapEntry":[{"theKey":{"@class":"string","$":"tabsObjects"},"theValue":{"@class":"string","$":"LIST"}},{"theKey":{"@class":"string","$":"dualSelects"},"theValue":{"@class":"string","$":"LIST"}},{"theKey":{"@class":"string","$":"marshalTypes"},"theValue":{"@class":"string","$":"LIST"}},{"theKey":{"@class":"string","$":"ajaxElements"},"theValue":{"@class":"string","$":"LIST"}},{"theKey":{"@class":"string","$":"fastUseValidationAlerts"},"theValue":{"@class":"string","$":"PRIMITIVE"}},{"theKey":{"@class":"string","$":"fastDontUseValidationImages"},"theValue":{"@class":"string","$":"PRIMITIVE"}},{"theKey":{"@class":"string","$":"useOriginalJavascriptAlert"},"theValue":{"@class":"string","$":"PRIMITIVE"}},{"theKey":{"@class":"string","$":"tabObjects"},"theValue":{"@class":"string","$":"LIST"}}]},"ajaxElements":{"AjaxMapEntry":[{"theKey":{"@class":"string","$":"T2XUSX0O"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX0P","screenElementId":"T2XUSX0O","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX0Q"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX0R","screenElementId":"T2XUSX0Q","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX0S"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX0T","screenElementId":"T2XUSX0S","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX0U"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX0V","screenElementId":"T2XUSX0U","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX0W"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX0X","screenElementId":"T2XUSX0W","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX0Y"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX0Z","screenElementId":"T2XUSX0Y","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX00"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX01","screenElementId":"T2XUSX00","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX02"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX03","screenElementId":"T2XUSX02","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX04"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX05","screenElementId":"T2XUSX04","disableValidation":false}},{"theKey":{"@class":"string","$":"T2XUSX06"},"theValue":{"@class":"AjaxEvent","ajaxEventType":"NORMAL","eventName":"onclick","ajaxId":"T2XUSX07","screenElementId":"T2XUSX06","disableValidation":false}}]},"useOriginalJavascriptAlert":false,"fastDontUseValidationImages":false,"fastUseValidationAlerts":false,"namesToClear":{"AjaxMapEntry":[{"theKey":{"@class":"string","$":"changeTerm1"},"theValue":{"@class":"string","$":"FORM"}},{"theKey":{"@class":"string","$":"T2XUSX0O"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX0Q"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX0S"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX0U"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX0W"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX0Y"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX00"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX02"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX04"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX06"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX09"},"theValue":{"@class":"string","$":"BUTTON"}},{"theKey":{"@class":"string","$":"T2XUSX1A"},"theValue":{"@class":"string","$":"BUTTON"}}]}}};
            fastInitFastResponse();
            $(document).ready(
            function(){
            var fastBlurDiv = document.getElementById("fastBlurDiv");
            if (!fastBlurDiv || !fastBlurDiv.parentNode){
            return;
            }
            fastBlurDiv.parentNode.removeChild(fastBlurDiv);
            });
            function fastElementUser_T2XUSX0M_onchange(event){
            javascript:document.forms['changeTerm1'].submit();
            }
            
            function fastColorOfErrors() {
            return 'red';
            }
            </script>
            </body>
            </html>
            """
        }
    }
}
