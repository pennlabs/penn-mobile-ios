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
                        .font(.callout)
                        .padding(4)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(vm.roomsAtSelectedLocation.hasAvailableAt(firstSlot.startTime) ? Color("gsrAvailable") : Color("gsrUnavailable"))
                        }
                        .frame(width: 80)
                    ForEach(avail, id: \.self) { slot in
                        Text(slot.endTime.gsrTimeString)
                            .font(.callout)
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(vm.roomsAtSelectedLocation.hasAvailableAt(slot.endTime) ? Color("gsrAvailable") : Color("gsrUnavailable"))
                            }
                            .frame(width: 80)
                    }
                }
                    
                
                
            }
        }
        
    }
}
