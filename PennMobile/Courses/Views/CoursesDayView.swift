//
//  CoursesDayView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI
import PennSharedCode

/// View that displays courses in a given day. Formats the title of the day and puts it in a ``CardView``.
struct CoursesDayView: View {
    var day: Int
    var entries: [CourseScheduleEntry]

    var body: some View {
        let sortedEntries = entries.sorted {
            ($0.meetingTime.startTime, $0.meetingTime.endTime, $0.course.code, $0.course.crn) <
                ($1.meetingTime.startTime, $1.meetingTime.endTime, $1.course.code, $1.course.crn)
        }

        let title = Date.weekdayArray[day - 1]

        return CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.title2).fontWeight(.medium)
                if sortedEntries.isEmpty {
                    Text("You have no classes on \(title)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                } else {
                    ScheduleView(entries: sortedEntries)
                }
            }.padding()
        }
    }
}
