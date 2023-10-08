//
//  FitnessRoomRow.swift
//  PennMobile
//
//  Created by Jordan H on 4/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct FitnessRoomRow: View {
    let room: FitnessRoom
    @State var isExpanded = false
    let meterSize: CGFloat = 80
    let meterLineWidth: CGFloat = 6
    var weekdayIndex: Int = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
    var hours: (Date, Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        let openTime = timeFormatter.date(from: room.open[weekdayIndex])!
        let closeTime = timeFormatter.date(from: room.close[weekdayIndex])!

        let openDate = calendar.date(bySettingHour: openTime.hour, minute: openTime.minutes, second: 0, of: currentDate)!
        let closeDate = calendar.date(bySettingHour: closeTime.hour, minute: closeTime.minutes, second: 0, of: currentDate)!
        
        return (openDate, closeDate)
    }
    var isOpen: Bool {
        let date = Date()
        return hours.0 < date && date < hours.1
    }

    var body: some View {
        VStack {
            HStack(spacing: 13) {
                KFImage(room.image_url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 64)
                    .background(Color.grey1)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                
                VStack(alignment: .leading, spacing: 3) {
                    Label(isOpen ? "Open" : "Closed", systemImage: isOpen ? "circle.fill" : "xmark.circle.fill")
                        .labelStyle(VenueStatusLabelStyle())
                        .foregroundColor(isOpen ? Color.green : Color.gray)
                    Text(room.name)
                        .font(.system(size: 17, weight: .medium))
                        .lineLimit(1)
                    Text(FitnessRoomRow.formattedHours(open: hours.0, close: hours.1))
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .foregroundColor(Color.labelPrimary)
                        .background(Color.grey5)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .frame(height: 64)
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 28, alignment: .center)
            }
            if isExpanded {
                VStack {
                    CardView {
                        VStack {
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("\(formatHour(date: Date())) ")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.blue)
                                Text(getBusyString())
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundColor(Color.labelPrimary)
                                Spacer()
                                Text(formattedLastUpdated(date: room.last_updated))
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(Color.labelSecondary)
                                    .lineLimit(1)
                            }
                            FitnessGraph(room: room)
                        }
                        .padding()
                    }
                    HStack {
                        CardView {
                            VStack(spacing: 10) {
                                ForEach(calculateWeeklyHours(open: room.open, close: room.close), id: \.self.0) { value in
                                    let inRange = value.0 <= weekdayIndex && weekdayIndex <= value.1
                                    HStack {
                                        Text(formatWeeklyHours(start: value.0, end: value.1))
                                        Spacer()
                                        Text(value.2)
                                    }
                                    .font(.system(size: 16, weight: inRange ? .medium : .light))
                                    .foregroundColor(inRange ? Color.blue : Color.labelPrimary)
                                }
                            }
                            .padding()
                        }
                        .frame(height: meterSize + 32)
                        CardView {
                            MeterView(current: room.capacity, maximum: 100.0, style: Color.blue, lineWidth: meterLineWidth) {
                                VStack {
                                    Text("\(room.capacity, specifier: "%.2f")%")
                                    Text("capacity")
                                        .font(.system(size: 10, weight: .light, design: .default))
                                }
                            }
                            .frame(width: meterSize, height: meterSize)
                            .padding()
                        }
                        .frame(width: meterSize + 32, height: meterSize + 32) // 32 is padding on both sides
                    }
                }
                .padding(.top)
                .animation(.easeInOut, value: isExpanded)
            }
        }
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    static func formattedHours(open: Date, close: Date, space: Bool = true, includeEmptyMinutes: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        formatter.dateFormat = (includeEmptyMinutes || open.minutes != 0) ? "h:mma" : "ha"
        let open = formatter.string(from: open)
        formatter.dateFormat = (includeEmptyMinutes || close.minutes != 0) ? "h:mma" : "ha"
        let close = formatter.string(from: close)

        return space ? "\(open) - \(close)" : "\(open)-\(close)"
    }
    
    func formattedLastUpdated(date: Date) -> String {
        let interval = -date.timeIntervalSinceNow
        let hours = Int(interval / 3600)
        let minutes = Int((interval - 3600 * Double(hours)) / 60)
        if hours == 0 {
            return "Updated \(minutes)m ago"
        }
        return "Updated \(hours)h \(minutes)m ago"
    }
    
    func formatHour(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
    
    func getBusyString(date: Date = Date()) -> String {
        if date < hours.0 || date > hours.1 {
            return "Closed"
        }
        if room.capacity == 0.0 {
            return "Empty"
        } else if room.capacity < 10.0 {
            return "Not very busy"
        } else if room.capacity < 30.0 {
            return "Slightly busy"
        } else if room.capacity < 60.0 {
            return "Pretty busy"
        } else if room.capacity < 90.0 {
            return "Extremely busy"
        } else {
            return "Packed"
        }
    }
    
    func calculateWeeklyHours(open: [String], close: [String]) -> [(Int, Int, String)] {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        var hours = [(Int, Int, String)]()
        for i in 0..<7 {
            if i != 0 && open[i] == open[i - 1] && close[i] == close[i - 1] {
                hours[hours.count - 1].1 += 1
            } else {
                let openTime = timeFormatter.date(from: open[i])!
                let closeTime = timeFormatter.date(from: close[i])!
                hours.append((i, i, FitnessRoomRow.formattedHours(open: openTime, close: closeTime, space: false, includeEmptyMinutes: false)))
            }
        }
        if hours.count > 1 && hours[0].2 == hours[hours.count - 1].2 {
            hours[0].0 = hours[hours.count - 1].0
            hours.removeLast()
        }
        let currentLoc = hours.firstIndex { $0.0 <= weekdayIndex && weekdayIndex <= $0.1 }!
        return Array((hours[currentLoc..<hours.count] + hours[0..<currentLoc]).prefix(3))
    }
    
    func formatWeeklyHours(start: Int, end: Int) -> String {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        if start == end {
            return weekdays[start]
        } else {
            return weekdays[start].prefix(3) + " - " + weekdays[end].prefix(3)
        }
    }
}
