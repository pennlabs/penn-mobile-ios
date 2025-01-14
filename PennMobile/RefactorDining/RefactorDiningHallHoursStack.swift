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
        HStack(spacing: 4){
            ForEach(hours) { meal in
                Text(meal.getHumanReadableHours())
                    .foregroundStyle(meal == currentStatus?.relevantMeal ? currentStatus?.secondaryColor ?? Color.primary : Color.primary)
                    .font(.caption)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(meal == currentStatus?.relevantMeal ? currentStatus?.color ?? Color.grey2 : Color.grey2)
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
        
        // Adjust formatter based on the time details
        if isSamePeriod && startMinute == 0 && endMinute == 0 {
            if startHour < 12 {
                // Case 1: Morning hours
                return "\(startHour)-\(endHour)AM"
            } else {
                // Case 3: Afternoon/evening hours
                return "\(startHour - 12)-\(endHour - 12)PM"
            }
        } else if isSamePeriod {
            // Case 4: Minutes or less obvious periods
            formatter.dateFormat = "h:mm"
            let startTimeString = formatter.string(from: startTime)
            formatter.dateFormat = "h"
            let endTimeString = formatter.string(from: endTime)
            return "\(startTimeString)-\(endTimeString)\(startHour < 12 ? "AM" : "PM")"
        } else {
            // Case 2: Crossing AM/PM boundary
            formatter.dateFormat = "h"
            let startTimeString = formatter.string(from: startTime)
            let endTimeString = formatter.string(from: endTime)
            return "\(startTimeString)-\(endTimeString)"
        }
    }
}


