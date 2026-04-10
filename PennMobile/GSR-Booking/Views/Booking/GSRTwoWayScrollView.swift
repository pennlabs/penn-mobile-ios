//
//  GSRTwoWayScrollView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import SwiftUI

let roomTitleOffset: CGFloat = 80

private struct GSRTwoWayScrollViewHeader: View {    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            GSRTimeCardRow()
                .padding(.top)
            TimeSlotDottedLinesView()
                .frame(height: 32)
        }
        .padding(.leading, roomTitleOffset - GSRTimeCardFilterToggle.width / 2)
    }
}

private struct GSRTwoWayScrollViewRoomRows: View {
    var relevantRooms: [GSRRoom]
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 48) {
            ForEach(relevantRooms, id: \.self) { room in
                GSRRoomAvailabilityRow(room: room)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(room.roomNameShort)
            }
            Spacer()
        }
        .accessibilityRotor("Rooms") {
            ForEach(relevantRooms, id: \.self) { room in
                AccessibilityRotorEntry(room.roomNameShort, id: room)
            }
        }
        .overlay {
            TimeSlotDottedLinesView()
        }
        .padding(.trailing, 48)
    }
}

private struct GSRTwoWayScrollViewRoomLabels: View {
    var relevantRooms: [GSRRoom]
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 48) {
            ForEach(relevantRooms, id: \.self) { room in
                Text(room.roomNameShort)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding(4)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.background)
                    }
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .frame(width: roomTitleOffset, height: 60)
                    .tag(room)
                    .accessibilityHidden(true)
            }
        }
    }
}

private struct GSRTwoWayScrollViewContent: View {
    @EnvironmentObject var vm: GSRViewModel
    
    var width: CGFloat
    
    // Pin the time card header to the scrollview
    @State var scrollViewPosition: CGFloat = 0.0
    
    var body: some View {
        let relevantRooms = vm.roomsAtSelectedLocation.filter {
            vm.settings.shouldShowFullyUnavailableRooms || $0.availability.contains(where: { $0.isAvailable })
        }
        
        VStack(spacing: 0) {
            GSRTwoWayScrollViewHeader()
                .offset(x: -scrollViewPosition)
                .frame(width: width, alignment: .leading)
                .clipped()

            ScrollView(.vertical, showsIndicators: false) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        GSRTwoWayScrollViewRoomRows(relevantRooms: relevantRooms)
                            .padding(.leading, roomTitleOffset)
                            .onGeometryChange(for: CGFloat.self) {
                                $0.frame(in: .scrollView).minX
                            } action: { x in
                                scrollViewPosition = -x
                            }
                            .background(Color(.systemBackground))
                    }
                }
                .overlay(alignment: .topLeading) {
                    GSRTwoWayScrollViewRoomLabels(relevantRooms: relevantRooms)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Timeslot Selector")
        .frame(width: width)
    }
}

struct GSRTwoWayScrollView: View {
    var body: some View {
        GeometryReader { proxy in
            GSRTwoWayScrollViewContent(width: proxy.size.width)
        }
    }
}
