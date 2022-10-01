//
//  CoursesDayView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct CourseScheduleEntry {
    var course: Course
    var meetingTime: MeetingTime
}

struct CoursesDayView: View {
    var day: Int
    var entries: [CourseScheduleEntry]
    
    var body: some View {
        let sortedEntries = entries.sorted {
            // TODO: Find a better way to sort this for accessibility reasons
            if $0.course.code < $1.course.code {
                return true
            } else if $0.course.code > $1.course.code {
                return false
            } else {
                return $0.course.crn < $1.course.crn
            }
        }
        
        let title = Date.weekdayArray[day - 1]
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title2).fontWeight(.medium)
            if sortedEntries.isEmpty {
                Text("You have no classes on \(title)")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            } else {
                ForEach(Array(sortedEntries.enumerated()), id: \.0) { entry in
                    let course = entry.1.course
                    
                    Text(course.code).fontWeight(.bold) + Text(" - \(course.title)") + Text(" (\(course.section))").foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.uiCardBackground)
        .cornerRadius(16)
    }
}
