//
//  GSRTwoWayScrollView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import SwiftUI

struct GSRTwoWayScrollView: View {
    @EnvironmentObject var vm: GSRViewModel
    
    let roomTitleOffset: CGFloat = 60
    
    var body: some View {
        ScrollView([.vertical, .horizontal], showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    LazyHStack(alignment: .center, spacing: 0, pinnedViews: .sectionHeaders) {
                        Section {
                            VStack(alignment: .leading, spacing: 32) {
                                ForEach(vm.roomsAtSelectedLocation, id: \.self) { room in
                                    GSRRoomAvailabilityRow(room: room)
                                }
                                Spacer()
                            }
                            .overlay {
                                TimeSlotDottedLinesView()
                            }
                            .offset(x: -8)
                        } header: {
                            HStack(alignment: .center, spacing: 0) {
                                VStack(alignment: .center, spacing: 32) {
                                    ForEach(vm.roomsAtSelectedLocation, id: \.self) { room in
                                        Text(room.roomName)
                                            .multilineTextAlignment(.center)
                                            .frame(width: roomTitleOffset, height: 42)
                                            .shadow(radius: 2)
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                    
                } header: {
                    VStack(alignment: .center, spacing: 0) {
                        GSRTimeCardRow()
                            .offset(x: -40)
                            .padding(.top)
                        TimeSlotDottedLinesView()
                            .frame(height: 16)
                    }
                    .offset(x: roomTitleOffset)
                    .background {
                        Rectangle()
                            .foregroundStyle(Color(UIColor.systemBackground))
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
