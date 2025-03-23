//
//  GSRTimeCardRow.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRTimeCardRow: View {
    @EnvironmentObject var vm: GSRViewModel
    var body: some View {
        if let first = vm.roomsAtSelectedLocation.first {
            HStack(spacing: 0) {
                let relevantAvailability: [GSRTimeSlot] = first.availability.filter {
                    let cal = Calendar.current
                    return cal.isDate($0.startTime, inSameDayAs: vm.selectedDate) || cal.isDate($0.endTime, inSameDayAs: vm.selectedDate)
                }
                if let firstSlot = relevantAvailability.first {
                    Text(getTimeString(firstSlot.startTime))
                        .frame(width: 80)
                    ForEach(relevantAvailability, id: \.self) { slot in
                        Text(getTimeString(slot.endTime))
                            .frame(width: 80)
                    }
                }
                
                
            }
        }
        
    }
    
    func getTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        return formatter.string(from: date)
    }
}
