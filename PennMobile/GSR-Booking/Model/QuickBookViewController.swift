//
//  QuickBookViewController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 2/23/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import PennMobileShared

class QuickBookViewModel: ObservableObject {
    
    @Published var location: GSRLocation? = nil
    @Published var soonestDetails: BookingItem? = nil
    @Published var alert: (title: String, message: String)? = nil
    fileprivate var allRooms: [GSRRoom] = []
    
    struct BookingItem: Identifiable {
        var id: Int { room.id }
        var slot: GSRTimeSlot
        var room: GSRRoom
    }

    @MainActor
    internal func populateSoonestTimeslot(location: GSRLocation, duration: Int, time: Date) async {
        do {
            self.location = location
            let avail = try await GSRNetworkManager.getAvailability(for: location, startDate: Date.now, endDate: Date.now)
            self.allRooms = avail
            soonestDetails = getSoonestTimeSlot(duration: duration, startTime: time)
        } catch {
            self.alert = ("Error", "Failed to fetch availability.")
        }
    }
    
    @MainActor
    func quickBook() {
        var booking : GSRBooking? = nil
        if !Account.isLoggedIn {
            self.alert = ("Error", "You are not logged in!")
            return;
        } else {
            if let timeSlot : GSRTimeSlot = soonestDetails?.slot {
                let timeRoom : GSRRoom = soonestDetails!.room
                booking = GSRBooking(gid: location!.gid, startTime: timeSlot.startTime, endTime: timeSlot.endTime, id: timeRoom.id, roomName: timeRoom.roomName)
            } else {
                self.alert = ("Error", "Error getting a room. Please try again.")
                return;
            }
        }
                
        Task { @MainActor in
                    do {
                        try await GSRNetworkManager.makeBooking(for: booking!)
                        FirebaseAnalyticsManager.shared.trackEvent(action: .attemptBooking, result: .success, content: booking!.roomName)
                        self.alert = ("Success!", "You booked \(booking!.roomName). A confirmation email is on its way.")
                    } catch {
                        FirebaseAnalyticsManager.shared.trackEvent(action: .attemptBooking, result: .failed, content: booking!.roomName)
                        self.alert = ("Uh oh!", "You seem to have exceeded the booking limit for this venue.")
                    }
                }
    }
//    
//    private func getSoonestTimeSlot(duration: Int, time: Date) -> BookingItem? {
//        let formatter = DateFormatter()
//        var current: BookingItem?
//        var start : Date = .distantFuture
//        formatter.timeZone = TimeZone.current
//        formatter.dateFormat = "HH:mm"
//        for room in allRooms {
//            guard let availability = room.availability.first(where: { $0.startTime >= Date() }) else {
//                continue
//            }
//            
//            if availability.startTime < start {
//                current?.slot = availability
//                current?.room = room
//                start = availability.startTime
//            }
//        }
//
//        return current
//    }
    
    private func getSoonestTimeSlot(duration: Int, startTime: Date) -> BookingItem? {
            let minInterval = TimeInterval(duration)
            var current: BookingItem?
            var start = Date.distantFuture

            for room in allRooms {
                if let slot = room.availability.filter({ $0.startTime >= start && $0.endTime.timeIntervalSince($0.startTime) >= minInterval }).sorted(by: {
                    $0.startTime < $1.startTime }).first {
                    if slot.startTime < start {
                        start = slot.startTime
                        current = BookingItem(slot: slot, room: room)
                    }
                }
            }
            return current
        }
}
