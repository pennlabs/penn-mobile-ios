//
//  GSRTwoWayScrollView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRTwoWayScrollView: View {
    static let roomLabelWidth: CGFloat = 80
    
    let rooms: [GSRRoom]
    let headerTimes: [Date]
    let availableStartTimes: Set<Date>
    let sortedStartTimes: [Date]
    let selectedSlotIDs: Set<UUID>
    let onToggleSlot: (GSRTimeSlot, GSRRoom) -> Void
    let onToggleSort: (Date) -> Void
    
    @State private var horizontalOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                GSRTimeHeaderView(
                    times: headerTimes,
                    availableStartTimes: availableStartTimes,
                    sortedStartTimes: sortedStartTimes,
                    onToggleSort: onToggleSort
                )
                .padding(.leading, Self.roomLabelWidth - GSRTimeSlotCell.width / 2)
                .offset(x: -horizontalOffset)
                .frame(width: proxy.size.width, alignment: .leading)
                .clipped()
                
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        GSRRoomRowsView(
                            rooms: rooms,
                            dividerCount: headerTimes.count,
                            selectedSlotIDs: selectedSlotIDs,
                            onToggleSlot: onToggleSlot
                        )
                        .padding(.leading, Self.roomLabelWidth)
                        .onGeometryChange(for: CGFloat.self) {
                            $0.frame(in: .scrollView).minX
                        } action: { x in
                            horizontalOffset = -x
                        }
                        .background(Color(.systemBackground))
                    }
                    .overlay(alignment: .topLeading) {
                        GSRRoomLabelsView(rooms: rooms, width: Self.roomLabelWidth)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Timeslot Selector")
            .frame(width: proxy.size.width)
        }
    }
}
