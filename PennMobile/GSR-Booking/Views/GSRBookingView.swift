//
//  GSRBookingView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRBookingView: View {
    
    static var pickerOptions: [Date] = (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date.now.localTime) }
    static var locationOptions: [GSRLocation] = [GSRLocation(lid: "ASDF", gid: 123, name: "Weigle", kind: .libcal, imageUrl: "https://google.com")]
    
    @EnvironmentObject var vm: GSRViewModel
    
    var body: some View {
        VStack {
            Picker("Location", selection: $selectedLoc) {
                ForEach(GSRBookingView.locationOptions, id: \.self) { loc in
                    Text(loc.name)
                }
            }
            .padding()
            Picker("Date", selection: $selectedDate) {
                ForEach(GSRBookingView.pickerOptions, id: \.self) { option in
                    Text(option.localizedGSRText)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        LazyVStack(alignment: .leading, spacing: 32, pinnedViews: .sectionHeaders) {
                            Section {
                                VStack(alignment: .leading, spacing: 32) {
                                    ForEach(tempRooms, id: \.self) { room in
                                        GSRRoomAvailabilityRow(room: room)
                                    }
                                    Spacer()
                                }
                                .overlay {
                                    TimeSlotDottedLinesView()
                                }
                            } header: {
                                GSRTimeCardRow(start: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date.now)!, end: Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: Date.now)!)
                                    .frame(height: 42)
                                    .offset(x: -40)
                                    .background {
                                        Rectangle()
                                            .foregroundStyle(Color(UIColor.systemBackground))
                                    }
                            }
                        }
                        
                    } header: {
                        HStack(spacing: 0) {
                            VStack(alignment: .center, spacing: 32) {
                                Rectangle()
                                    .foregroundStyle(Color(UIColor.systemBackground))
                                    .frame(width: 80, height: 42)
                                ForEach(tempRooms, id: \.self) { room in
                                    Text(room.roomName)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 80, height: 42)
                                }
                                Spacer()
                            }
                            Rectangle()
                                .frame(width: 1)
                                .foregroundStyle(Color(UIColor.systemGray))
                        }
                        .background(.background)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            HStack(spacing: 12) {
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                    }
                } label: {
                    Label("Find me a room", systemImage: "wand.and.sparkles")
                        .font(.body)
                        .foregroundStyle(Color(UIColor.systemGray))
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.white)
                                .shadow(radius: 2)
                        }
                        

                }
                
                if !vm.selectedTimeslots.isEmpty {
                    Button {
                        
                    } label: {
                        Text("Book")
                            .font(.body)
                            .bold()
                            .foregroundStyle(Color.white)
                            .padding(8)
                            .padding(.horizontal, 24)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color("gsrBlue"))
                                    .shadow(radius: 2)
                            }
                        
                        
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    //                .opacity(tempDisabled ? 0.2 : 1.0)
                    //                .allowsHitTesting(!tempDisabled)
                }
            }
            .padding(.vertical, 32)
            .background(.background)
            
        }
            .navigationTitle("Choose a Time Slot")
    }
}

extension Date {
    var localizedGSRText: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }
        
        let weekday = Calendar.current.component(.weekday, from: self)
        let abbreviations = [
            1: "S", // Sunday
            2: "M", // Monday
            3: "T", // Tuesday
            4: "W", // Wednesday
            5: "R", // Thursday
            6: "F", // Friday
            7: "S"  // Saturday
        ]
            
        return abbreviations[weekday] ?? ""
    }
}

#Preview {
    var tempRooms = [GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ]), GSRRoom(roomName: "Room 100", id: 100, availability: [
        GSRTimeSlot(startTime: Date.now, endTime: Date.now.advanced(by: 1800), isAvailable: true),
        GSRTimeSlot(startTime: Date.now.advanced(by: 1800), endTime: Date.now.advanced(by: 3600), isAvailable: false)
    ])]
    GSRBookingView(tempRooms: tempRooms)
}
