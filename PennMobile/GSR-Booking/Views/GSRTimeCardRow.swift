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
                    Text(firstSlot.startTime.gsrTimeString)
                        .frame(width: 80)
                    ForEach(avail, id: \.self) { slot in
                        Text(slot.endTime.gsrTimeString)
                            .frame(width: 80)
                    }
                }
                
                
            }
        }
        
    }
}
