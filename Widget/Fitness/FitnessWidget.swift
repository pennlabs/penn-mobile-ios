//
//  FitnessWidget.swift
//  PennMobile
//
//  Created by Pulkith Paruchuri on 10/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import PennMobileShared
import WidgetKit

extension ConfigureFitnessWidgetIntent: ConfigurationRepresenting {
    struct Configuration {
        let background: WidgetBackgroundType
        let complex: FitnessChosenComplex
    }
    
    var configuration: Configuration {
        return Configuration(background: background, complex: complex)
    }
}

/* Code from FitnessRoomRow */
private func lastUpdatedFormattedTime (date: Date) -> String {
    let interval = -date.timeIntervalSinceNow
    let hours = Int(interval / 3600)
    let minutes = Int((interval - 3600 * Double(hours)) / 60)
    if hours == 0 {
        return "Updated \(minutes)m ago"
    }
    return "Updated \(hours)h \(minutes)m ago"
}

private func getBusyString(room: FitnessRoom) -> String {
    let hours = getHours(room: room)
    let date = Date()
    if date < hours.0 || date > hours.1 {
        return ""
    } else if room.capacity == 0.0 {
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

private func getOpenString(room: FitnessRoom, showbusystring: Bool) -> String {
    let hours = getHours(room: room)
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"

    if(date < hours.0) {
        return "Closed • Opens at " + dateFormatter.string(from: hours.0).replacingOccurrences(of: ":00", with: "")
    } else if (hours.0 <= date && date <= hours.1) {
        return "Open until " + dateFormatter.string(from: hours.1).replacingOccurrences(of: ":00", with: "") + ((showbusystring) ? (" • " + getBusyString(room: room)) : "")
    } else {
        return "Closed"
    }
}

private func getHours (room: FitnessRoom) -> (Date, Date) {
    let weekdayIndex: Int = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
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
    return hours
}

private func isOpen (room: FitnessRoom) -> Bool {
    let date = Date()
    let hours = getHours(room: room)
    return hours.0 <= date && date <= hours.1
}



private struct FitnessWidgetSmallView: View {
    var room: FitnessRoom
    var configuration: ConfigureFitnessWidgetIntent.Configuration
    
    
    var body: some View {
        VStack {
            Text(room.name)
                .font(.system(size: 13, weight: .semibold))
                .padding(.top)
                .foregroundStyle(configuration.background.prefersGrayscaleContent  ? Color.primary : .black)
            Text(getOpenString(room: room, showbusystring: false))
                .font(.system(size: 11))
                .foregroundStyle(configuration.background.prefersGrayscaleContent ? Color.primary : (isOpen(room: room) ? .green : .blue))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            MeterView(current: isOpen(room: room) ? room.capacity : 0, maximum: 100.0, style: (configuration.background.prefersGrayscaleContent  ? Color.primary : .blue), lineWidth: 6) {
                VStack {
                    Text("\(isOpen(room: room) ? room.capacity : 0, specifier: "%.2f")%")
                        .fontWeight(.bold)
                        .foregroundStyle(configuration.background.prefersGrayscaleContent  ? Color.primary : .black)
                    Text("capacity")
                        .font(.system(size: (configuration.background.prefersGrayscaleContent ? 13 : 10), weight: .light, design: .default))
                        .foregroundStyle(configuration.background.prefersGrayscaleContent  ? Color.primary : .black)
                    
                }
            }
            .frame(width: 90, height: 90)
            
            Text(lastUpdatedFormattedTime(date: room.last_updated))
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}


private struct FitnessWidgetMediumView: View {
    var room: FitnessRoom
    var configuration: ConfigureFitnessWidgetIntent.Configuration
    
    var body: some View {
        HStack {
            VStack {
                Text(room.name)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.top)
                    .foregroundStyle(configuration.background.prefersGrayscaleContent  ? Color.primary : .black)
                VStack {
                    MeterView(current: isOpen(room: room) ? room.capacity : 0, maximum: 100.0, style: configuration.background.prefersGrayscaleContent  ? Color.primary : .blue, lineWidth: 6) {
                        VStack {
                            Text("\(isOpen(room: room) ? room.capacity : 0, specifier: "%.2f")%")
                                .fontWeight(.bold)
                                .foregroundStyle(configuration.background.prefersGrayscaleContent  ? Color.primary : .black)
                            Text("capacity")
                                .font(.system(size: (configuration.background.prefersGrayscaleContent ? 13 : 10), weight: .light, design: .default))
                                .foregroundStyle(configuration.background.prefersGrayscaleContent  ? Color.primary : .black)
                            
                        }
                    }
                    .frame(width: 90, height: 90)
                    
                    Text(lastUpdatedFormattedTime(date: room.last_updated))
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom)
            
            }
            .padding([.trailing, .leading], 10)
            
            VStack {
                Text(getOpenString(room: room, showbusystring: true))
                    .font(.system(size: 12))
                    .foregroundStyle(configuration.background.prefersGrayscaleContent  ? Color.primary : (isOpen(room: room) ? .green : .blue))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top)
                
                FitnessGraph(room: room, color: configuration.background.prefersGrayscaleContent ? Color.primary : .blue)
                    .padding(.bottom)
            }.padding([.trailing], 10)
        }.widgetPadding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FitnessHomeWidgetView: View {
    var entry: FitnessEntry<ConfigureFitnessWidgetIntent.Configuration>
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        Group {
            if (entry.roomID == 0) {
                Text("To use this widget, choose a room by **touching and holding the widget**, then choosing **Edit Widget**.")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .font(.system(size: 12))
            }
            else if (entry.room == nil) {
                Text("Error fetching fitness room data.")
                    .multilineTextAlignment(.center).widgetPadding()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .font(.system(size: 15))
            }
            else {
                let room = entry.room!
                switch widgetFamily {
                    case .systemSmall: FitnessWidgetSmallView(room: room, configuration: entry.configuration)
                    case .systemMedium: FitnessWidgetMediumView(room: room, configuration: entry.configuration)
                    default: FitnessWidgetSmallView(room: room, configuration: entry.configuration)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(entry.configuration.background)
    }
    
}



struct FitnessHomeWidget: Widget {
    var body: some WidgetConfiguration {
        let provider = IntentFitnessProvider<ConfigureFitnessWidgetIntent>(placeholderConfiguration: .init(background: .unknown, complex: .unknown))
        return IntentConfiguration(kind: WidgetKind.fitnessHome, intent: ConfigureFitnessWidgetIntent.self, provider: provider) { entry in
            FitnessHomeWidgetView(entry: entry)
        }
        .configurationDisplayName("Fitness Information")
        .description("Fitness room information, at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
