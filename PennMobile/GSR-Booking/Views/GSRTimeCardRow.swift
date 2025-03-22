//
//  GSRTimeCardRow.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRTimeCardRow: View {
    let start: Date
    let end: Date
    var body: some View {
        HStack(spacing: 0) {
            ForEach(getIntermediateSlots(), id: \.self) { time in
                Text(getTimeString(time))
                    .font(.body)
                    .frame(width: 80)
            }
        }
        
    }
    
    func countIntermediateSlots() -> Int {
        return getIntermediateSlots().count
    }
    
    func getIntermediateSlots() -> [Date] {
        var times: [Date] = []
        var currentDate = start
        while currentDate < end {
            times.append(currentDate)
            currentDate = currentDate.addingTimeInterval(1800) // 1800 seconds = 30 minutes
        }
            
        // Add the last interval if it's within the end date
        if currentDate <= end {
            times.append(currentDate)
        }

        return times
    }
    
    func getTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        return formatter.string(from: date)
    }
}

#Preview {
    ScrollView {
        GSRTimeCardRow(start: Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: Date.now)!, end: Calendar.current.date(bySettingHour: 23, minute: 00, second: 0, of: Date.now)!)
    }
}
