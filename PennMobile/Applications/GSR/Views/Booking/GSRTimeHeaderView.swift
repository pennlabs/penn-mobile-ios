//
//  GSRTimeHeaderView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRTimeHeaderView: View {
    let times: [Date]
    let availableStartTimes: Set<Date>
    let sortedStartTimes: [Date]
    let onToggleSort: (Date) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(times, id: \.self) { time in
                    GSRTimeFilterToggle(
                        time: time,
                        isActive: sortedStartTimes.contains(time),
                        hasAvailability: availableStartTimes.contains(time)
                    ) {
                        onToggleSort(time)
                    }
                }
            }
            .padding(.top)
            
            GSRTimeSlotDividersView(count: times.count)
                .frame(height: 32)
        }
    }
}
