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
                let avail = vm.getRelevantAvailability()
                if let firstSlot = avail.first {
                    Text(getTimeString(firstSlot.startTime))
                        .frame(width: 80)
                    ForEach(avail, id: \.self) { slot in
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
