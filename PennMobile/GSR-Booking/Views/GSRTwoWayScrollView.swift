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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
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
                        
                    } header: {
                        VStack(alignment: .center, spacing: 0) {
                            GSRTimeCardRow()
                                .padding(.top)
                            TimeSlotDottedLinesView()
                                .frame(height: 16)
                        }
                        .offset(x: -40)
                        .background {
                            Rectangle()
                                .foregroundStyle(Color(UIColor.systemBackground))
                        }
                        
                    }
                }
                
            }
        }
        
        
//        ScrollView([.vertical, .horizontal], showsIndicators: false) {
//            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
//                Section {
//
//                    
//                } header: {
//HStack {

//        Spacer()
//    }
//
//                }
//            }
//        }
//        .scrollBounceBehavior(.basedOnSize)
    }
}
