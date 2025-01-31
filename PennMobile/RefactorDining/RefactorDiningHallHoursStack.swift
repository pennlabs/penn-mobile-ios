//
//  RefactorDiningHallHoursStack.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Foundation
import PennMobileShared

struct RefactorDiningHallHoursStack: View {
    let hours: [RefactorDiningMeal]
    let currentStatus: RefactorDiningHall.DiningHallStatus?
    
    
    var body: some View {
        ScrollView (.horizontal) {
            HStack(spacing: 4) {
                ForEach(hours) { meal in
                    Text(meal.getHumanReadableHours())
                        .foregroundStyle(meal == currentStatus?.relevantMeal ? currentStatus?.textColor ?? Color.primary : Color.primary)
                        .font(.system(.caption, weight: .light))
                        .padding(6)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(meal == currentStatus?.relevantMeal ? currentStatus?.bgColor ?? Color.grey6 : Color.grey6)
                        }
                }
            }
        }
    }
}


public extension RefactorDiningMeal {
    func getHumanReadableHours() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeZone = .current
        
        let calendar = Calendar.current
        
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        
        // Determine if both times are AM or PM
        let isSamePeriod = (startHour < 12 && endHour < 12) || (startHour >= 12 && endHour >= 12)
        
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        //AM
        formatter.dateFormat = "h\(startMinute != 0 ? ":mm" : "")"
        let startTimeString = formatter.string(from: startTime)
        
        //PM
        formatter.dateFormat = "h\(endMinute != 0 ? ":mm" : "")\(!isSamePeriod ? "" : "a")"
        let endTimeString = formatter.string(from: endTime)
        
        return "\(startTimeString)-\(endTimeString)"
    }
}


