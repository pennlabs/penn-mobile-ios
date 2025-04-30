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
    @Environment(\.presentToast) var presentToast
    let roomTitleOffset: CGFloat = 80
    
    // Pin the time card header to the scrollview
    @State var scrollViewCenterDisplacementValue: CGFloat = 0.0
    @State var totalCenterOffset: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                GSRTimeCardRow()
                    .padding(.top)
                TimeSlotDottedLinesView()
                    .frame(height: 32)
            }
            .padding(.trailing, 48)
            .background {
                GeometryReader { proxy in
                    Rectangle()
                        .foregroundStyle(Color(UIColor.systemBackground))
                        .onAppear {
                            self.totalCenterOffset -= proxy.frame(in: .global).midX
                        }
                }
            }
            .offset(x: totalCenterOffset + scrollViewCenterDisplacementValue)

            ScrollView(.vertical, showsIndicators: false) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        Color.clear
                            .frame(width: roomTitleOffset)
                        VStack(alignment: .center, spacing: 48) {
                            ForEach(vm.roomsAtSelectedLocation, id: \.self) { room in
                                GSRRoomAvailabilityRow(room: room)
                            }
                            Spacer()
                        }
                        .overlay {
                            TimeSlotDottedLinesView()
                        }
                        .padding(.trailing, 48)
                        .background {
                            GeometryReader { proxy in
                                Color.clear
                                    .onChange(of: proxy.frame(in: .global).midX) { old, new in
                                        scrollViewCenterDisplacementValue += new - old
                                    }
                                    .onAppear {
                                        self.totalCenterOffset += proxy.frame(in: .global).midX
                                    }
                            }
                        }
                    }
                }
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .center, spacing: 48) {
                        ForEach(vm.roomsAtSelectedLocation, id: \.self) { room in
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
                        }
                    }
                }
            }
        }
    }
}
