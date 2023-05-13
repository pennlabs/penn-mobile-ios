//
//  FitnessRoomRow.swift
//  PennMobile
//
//  Created by Jordan H on 4/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct FitnessRoomRow: View {

    init(for room: FitnessRoom) {
        self.room = room
    }

    let room: FitnessRoom
    var isOpen: Bool {
        let date = Date()
        return date >= room.open && date <= room.close
    }
    @State var isExpanded = false
    let meterSize: CGFloat = 80
    let meterLineWidth: CGFloat = 6

    var body: some View {
        VStack {
            HStack(spacing: 13) {
                Image("pottruck")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 64)
                    .background(Color.grey1)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(room.name)
                        .font(.system(size: 17, weight: .medium))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                    
                    GeometryReader { geo in
                        HStack(spacing: 6) {
                            Text(isOpen ? "Open" : "Closed")
                                .font(.system(size: 14, weight: .light, design: .default))
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .foregroundColor(isOpen ? Color.white : Color.labelPrimary)
                                .background(isOpen ? Color.greenLight : Color.redLight)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(height: geo.frame(in: .global).height)
                            Text(formattedHours(open: room.open, close: room.close))
                                .font(.system(size: 14, weight: .light, design: .default))
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .foregroundColor(Color.labelPrimary)
                                .background(Color.grey5)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(height: geo.frame(in: .global).height)
                        }
                    }
                }
                .frame(height: 64)
                
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 28, alignment: .center)
            }
            if isExpanded {
                VStack {
                    CardView {
                        VStack {
                            HStack(spacing: 0) {
                                Text("\(formatHour(date: Date())): ")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.blue)
                                Text(getBusyString())
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundColor(Color.labelPrimary)
                                Spacer()
                            }
                            FitnessGraph(room: room)
                        }
                        .padding()
                    }
                    HStack {
                        CardView {
                            VStack {
                                Text("Last updated")
                                Text(formattedLastUpdated(date: room.last_updated))
                            }
                        }
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
                    }
                }
                .padding(.top)
            }
        }
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    func formattedLastUpdated(date: Date) -> String {
        let interval = -date.timeIntervalSinceNow
        let hours = Int(interval / 3600)
        let minutes = Int((interval - 3600 * Double(hours)) / 60)
        return "\(hours) hours and \(minutes) minutes ago"
    }
    
    func formattedHours(open: Date, close: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        let open = formatter.string(from: open)
        let close = formatter.string(from: close)
        let timesString = "\(open) - \(close)"

        return timesString
    }
    
    func formatHour(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
    
    func getBusyString(date: Date = Date()) -> String {
        if date < room.open || date > room.close {
            return "Closed"
        }
        if room.capacity < 0.05 {
            return "Empty"
        } else if room.capacity < 0.2 {
            return "Slightly busy"
        } else {
            return "Busy"
        }
    }
}
