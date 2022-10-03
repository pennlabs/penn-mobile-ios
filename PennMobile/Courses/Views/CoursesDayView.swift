//
//  CoursesDayView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

/// Entry to display in the schedule view.
struct CourseScheduleEntry: Identifiable {
    let id = UUID()
    var course: Course
    var meetingTime: MeetingTime
    var color: Color
}

private let calendar = Calendar(identifier: .gregorian)
private let timezone = TimeZone(identifier: "EST")
private let hourFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.setLocalizedDateFormatFromTemplate("hh")
    return formatter
}()
private let hourSize: CGFloat = 48
private let textWidth: CGFloat = 40

private func getLineOpacity(time: Int) -> Double {
    if time % 60 == 0 {
        return 0.5
    } else if time % 30 == 0 {
        return 0.25
    } else {
        return 0.125
    }
}

/// View that displays a daily schedule of courses.
struct ScheduleView: View {
    var entries: [CourseScheduleEntry]

    var body: some View {
        let minTime = Int(floor(Double(entries.map { $0.meetingTime.startTime }.min()!) / 60)) * 60
        let maxTime = Int(ceil(Double(entries.map { $0.meetingTime.endTime }.max()!) / 60)) * 60

        return ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ForEach(Array(stride(from: minTime, through: maxTime, by: 15)), id: \.self) { time in
                    HStack(spacing: 0) {
                        Group {
                            if time % 60 == 0 {
                                let components = DateComponents(calendar: calendar, timeZone: timezone, hour: time / 60)
                                if let date = calendar.date(from: components), let str = hourFormatter.string(from: date) {
                                    Text(str).font(.caption)
                                } else {
                                    Spacer()
                                }
                            } else {
                                Spacer()
                            }
                        }.padding(.trailing, 4).frame(width: textWidth, alignment: .trailing)

                        VStack {
                            Rectangle().fill(Color.primary).frame(height: 1).opacity(getLineOpacity(time: time))
                        }
                    }.frame(height: hourSize / 4)
                }
            }.foregroundColor(.secondary)
            ForEach(entries) { entry in
                let course = entry.course
                let meetingTime = entry.meetingTime

                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        (
                            Text(course.code).fontWeight(.medium) + Text(": \(course.title)")
                        ).font(.callout).lineLimit(1)
                        Spacer(minLength: 8)
                        Text(course.section).fontWeight(.medium)
                    }.font(.callout)
                    if let location = course.location {
                        Text(location).font(.caption)
                    }
                }
                .font(.callout)
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: CGFloat(meetingTime.endTime - meetingTime.startTime) / 60 * hourSize, alignment: .top)
                .background(entry.color)
                .cornerRadius(4)
                .padding(.leading, textWidth)
                .offset(y: (CGFloat(meetingTime.startTime - minTime) / 60 + 1 / 4 / 2) * hourSize)
            }
        }
    }
}

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
