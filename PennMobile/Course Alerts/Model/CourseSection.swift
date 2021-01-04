//
//  CourseSection.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct CourseSection: Decodable {
    
    let section: String
    let status: String
    let activity: String
    let meetingTimes: String
    let instructors: [String]
    let courseTitle: String
    
    enum CodingKeys: String, CodingKey {
        case status, activity, instructors
        case section = "section_id"
        case meetingTimes = "meeting_times"
        case courseTitle = "course_title"
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
                
        let status: String = try keyedContainer.decode(String.self, forKey: .status)
        let activity: String = try keyedContainer.decode(String.self, forKey: .activity)
        let instructors: [String] = try keyedContainer.decode([String].self, forKey: .instructors)
        let section: String = try keyedContainer.decode(String.self, forKey: .section)
        let meetingTimes: String = try keyedContainer.decode(String.self, forKey: .meetingTimes)
        let courseTitle: String = try keyedContainer.decode(String.self, forKey: .courseTitle)
        
        self.status = status
        self.activity = activity
        self.instructors = instructors
        self.section = section
        self.meetingTimes = meetingTimes
        self.courseTitle = courseTitle
        
    }
    
}
