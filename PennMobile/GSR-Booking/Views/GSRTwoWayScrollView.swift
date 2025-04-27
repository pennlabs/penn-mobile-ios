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
    let roomTitleOffset: CGFloat = 60
    
    // Pin the time card header to the scrollview
    @State var scrollViewCenterDisplacementValue: CGFloat = 0.0
    @State var totalCenterOffset: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                GSRTimeCardRow()
                    .padding(.top)
                TimeSlotDottedLinesView()
                    .frame(height: 16)
            }
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
                    VStack(alignment: .center, spacing: 48) {
                        Color.clear
                            .frame(height: 0)
                        ForEach(vm.roomsAtSelectedLocation, id: \.self) { room in
                            GSRRoomAvailabilityRow(room: room)
                        }
                        Spacer()
                    }
                    .overlay {
                        TimeSlotDottedLinesView()
                    }
                    .padding(.horizontal, 40)
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
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 60) {
                        ForEach(vm.roomsAtSelectedLocation, id: \.self) { room in
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                Text(room.roomName)
                                    .padding(.horizontal, 4)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(8)
                            .frame(height: 48)
                            .tag(room)
                        }
                    }
                }
            }
        }
    }
}
