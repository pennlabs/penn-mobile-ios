//
//  GSRCalendarBookingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 8/24/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRCalendarBookingView: View {
    @EnvironmentObject var vm: GSRViewModel
    
    let debugAvail: [GSRTimeSlot] = [
        .init(startTime: Date.now.roundedDownToHalfHour, endTime: Date.now.roundedDownToHalfHour.addingTimeInterval(1800)),
        .init(startTime: Date.now.roundedDownToHalfHour.addingTimeInterval(1800), endTime: Date.now.roundedDownToHalfHour.addingTimeInterval(3600))
    ]
    
    // MARK: Params
    let overallCellSize: CGFloat = 60
    let cellBufferArea: CGFloat = 4
    let timeLineWidth: CGFloat = 1

    @State var textHeight: CGFloat = 0
    var body: some View {
        let avail = vm.getRelevantAvailability()
        HStack(spacing: 8) {
            VStack(spacing: overallCellSize - textHeight + 2 * cellBufferArea + timeLineWidth) {
                if let firstSlot = avail.first {
                    Text(firstSlot.startTime.gsrTimeString)
                        .background {
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        self.textHeight = proxy.size.height
                                    }
                                    .onChange(of: proxy.size.height) {
                                        self.textHeight = proxy.size.height
                                    }
                            }
                        }
                    ForEach(avail, id: \.self) { slot in
                        Text(slot.endTime.gsrTimeString)
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(Color(UIColor.systemGray))
            
            ZStack {
                VStack(spacing: overallCellSize) {
                    if let firstSlot = avail.first {
                        Rectangle()
                            .frame(height: timeLineWidth)
                            .padding(.vertical, cellBufferArea)
                        ForEach(avail, id: \.self) { slot in
                            Rectangle()
                                .frame(height: timeLineWidth)
                                .padding(.vertical, cellBufferArea)
                        }
                    }
                }
                .foregroundStyle(Color(UIColor.systemGray))
                
                VStack(spacing: 0) {
                    ForEach(avail, id: \.self) { slot in
                        // The rationale here is if we can't book for 30 minutes we can't book for anything else.
                        let hasAnyAvailability = !vm.roomsAvailable(startingAt: slot.startTime, consecutiveSlots: 1).isEmpty
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(hasAnyAvailability ? Color("gsrAvailable") : Color("gsrUnavailable"))
                            if hasAnyAvailability {
                                HStack {
                                    Spacer()
                                    ForEach(1..<(vm.selectedLocation?.kind.maxConsecutiveBookings ?? 3) + 1, id: \.self) { i in
                                        
                                        let available = vm.roomsAvailable(startingAt: slot.startTime, consecutiveSlots: i)
                                        
                                        VStack(spacing: 0) {
                                            Text("\(i * 30)")
                                                .font(.system(size: 20))
                                                .bold()
                                            Text("mins")
                                                .font(.system(size: 10))
                                        }
                                        .padding(2)
                                        .frame(width: overallCellSize - 8, height: overallCellSize - 8)
                                        .background {
                                            RoundedRectangle(cornerRadius: 4)
                                                .foregroundStyle(Color(available.isEmpty ? "gsrUnavailable" : "gsrAvailable"))
                                                .overlay {
                                                    if available.isEmpty {
                                                        UnavailableTextureOverlay()
                                                    }
                                                }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            } else {
                                UnavailableTextureOverlay()
                                Text("No rooms available")
                                    .font(.headline)
                            }
                        }
                            .frame(height: overallCellSize)
                            .padding(.vertical, cellBufferArea + 0.5 * timeLineWidth)
                    }
                    
                }
            }
        }
    }
}
