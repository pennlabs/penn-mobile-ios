//
//  ScheduleView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

private let colors: [Color] = [.redLight, .orangeLight, .yellowLight, .greenLight, .blueLight, .purpleLight]

/// Entry to display in the schedule view.
struct CourseScheduleEntry: Identifiable {
    let id = UUID()
    var course: Course
    var meetingTime: MeetingTime
    var color: Color
}

extension Course {
    func entries(for weekday: Int, color: Color) -> [CourseScheduleEntry] {
        meetingTimes?.filter { $0.weekday == weekday }.map {
            CourseScheduleEntry(course: self, meetingTime: $0, color: color)
        } ?? []
    }
}

extension Array where Element == Course {
    func computeColorAssignments() -> [Color] {
        var codesToColors = [String: Color]()
        var colorsUsed = 0
        sorted { $0.code < $1.code }.forEach {
            let color: Color
            if let theColor = codesToColors[$0.code] {
                color = theColor
            } else {
                color = colors[colorsUsed % colors.count]
                colorsUsed += 1
                codesToColors[$0.code] = color
            }
        }
        
        return map {
            codesToColors[$0.code]!
        }
    }
    
    func filterByDate(_ date: Date) -> [Course] {
        filter {
            if let start = $0.startDate, let end = $0.endDate {
                return start <= date && date <= end.addingTimeInterval(24 * 60 * 60)
            } else {
                return false
            }
        }
    }
    
    func entries(for weekday: Int) -> [CourseScheduleEntry] {
        zip(self, computeColorAssignments()).flatMap {
            let (course, color) = $0
            return course.entries(for: weekday, color: color)
        }
    }
}

private let calendar = Course.calendar
private let timezone = Course.timezone
private let hourFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.setLocalizedDateFormatFromTemplate("hh")
    return formatter
}()
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = timezone
    formatter.timeStyle = .short
    return formatter
}()
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

private func formatTime(_ time: Int) -> String {
    let components = DateComponents(calendar: calendar, timeZone: timezone, hour: time / 60, minute: time % 60)
    guard let date = calendar.date(from: components) else {
        return ""
    }
    return timeFormatter.string(from: date)
}

/// View that displays a daily schedule of courses.
struct ScheduleView: View {
    var entries: [CourseScheduleEntry]
    var minTime: Int?
    var maxTime: Int?
    var hourSize: CGFloat = 48
    var hourLabels = HourLabel.external
    var showSections = true
    var showColors = true
    
    struct HourLabel: OptionSet {
        var rawValue: UInt8
        
        static let external = HourLabel(rawValue: 1 << 0)
        static let inline = HourLabel(rawValue: 1 << 1)
    }
    
    func mask(minTime: Int, maxTime: Int) -> some View {
        return ZStack(alignment: .top) {
            ForEach(entries) { entry in
                let meetingTime = entry.meetingTime

                Spacer()
                .frame(height: CGFloat(meetingTime.endTime - meetingTime.startTime) / 60 * hourSize, alignment: .top)
                .background(Color.black)
                .cornerRadius(4)
                .padding(.leading, hourLabels.contains(.external) ? textWidth : 0)
                .offset(y: (CGFloat(meetingTime.startTime - minTime) / 60 + 1 / 4 / 2) * hourSize)
            }
        }
    }

    var body: some View {
        let minTime = minTime ?? Int(floor(Double(entries.map { $0.meetingTime.startTime }.min()!) / 60)) * 60
        let maxTime = maxTime ?? Int(ceil(Double(entries.map { $0.meetingTime.endTime }.max()!) / 60)) * 60

        return ZStack(alignment: .top) {
            let hourLines = VStack(spacing: 0) {
                ForEach(Array(stride(from: minTime, through: maxTime, by: 15)), id: \.self) { time in
                    HStack(spacing: 0) {
                        if hourLabels.contains(.external) {
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
                        }
                        
                        Rectangle().fill(Color.primary).frame(height: 1).opacity(getLineOpacity(time: time))
                    }.frame(height: hourSize / 4)
                }
            }
            .foregroundColor(.secondary)
            
            // https://www.fivestars.blog/articles/reverse-masks-how-to/
            if showColors {
                hourLines
            } else {
                hourLines.mask(alignment: .top) {
                    Rectangle().overlay(alignment: .top) {
                        mask(minTime: minTime, maxTime: maxTime).blendMode(.destinationOut)
                    }
                }
            }
            
            ForEach(entries) { entry in
                let course = entry.course
                let meetingTime = entry.meetingTime

                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        (
                            Text(course.code).fontWeight(.medium) + Text(": \(course.title)")
                        ).font(.callout).lineLimit(1)
                        if showSections {
                            Spacer(minLength: 8)
                            Text(course.section).fontWeight(.medium)
                        }
                    }.font(.callout)
                    if let location = course.location {
                        Text(location).font(.caption)
                    }
                    if hourLabels.contains(.inline) {
                        Spacer()
                        Text("\(formatTime(meetingTime.startTime))-\(formatTime(meetingTime.endTime))").font(.caption2)
                    }
                }
                .font(.callout)
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: CGFloat(meetingTime.endTime - meetingTime.startTime) / 60 * hourSize, alignment: .top)
                .background(showColors ? entry.color : Color.primary.opacity(0.1))
                .cornerRadius(4)
                .padding(.leading, hourLabels.contains(.external) ? textWidth : 0)
                .offset(y: (CGFloat(meetingTime.startTime - minTime) / 60 + 1 / 4 / 2) * hourSize)
            }
        }
    }
}
