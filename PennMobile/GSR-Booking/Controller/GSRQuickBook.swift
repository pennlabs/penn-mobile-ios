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

struct AlertContent: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let onAccept: (() -> Void)?
    let onCancel: (() -> Void)?
}

class GSRQuickBook: ObservableObject, GSRBookable {
    @EnvironmentObject var vm: GSRViewModel
    
    fileprivate var location: GSRLocation?
    fileprivate var soonestDetails: QuickRoomDetails?
    fileprivate var allRooms: [GSRRoom] = []
    fileprivate var selectedStartTime: Date?
    
    fileprivate struct QuickRoomDetails {
        var slot: GSRTimeSlot
        var room: GSRRoom
    }
    
    var onQuickBookSuccess: ((GSRBooking) -> Void)?
    
    @Published var activeAlert: AlertContent?
    
    func showAlert(withMsg: String, title: String, completion: (() -> Void)?) {}
    
    func showOption(withMsg: String, title: String, onAccept: (() -> Void)?, onCancel: (() -> Void)?) {}

    @MainActor
    internal func populateSoonestTimeslot(location: GSRLocation, duration: Int, time: Date) async throws{
        self.location = location
        let avail = try await GSRNetworkManager.getAvailability(for: location, startDate: Date.now, endDate: Date.now)
        self.allRooms = avail
        self.selectedStartTime = time
        soonestDetails = getSoonestTimeSlot(duration: duration, time: time)
    }
    
    
    private func getSoonestTimeSlot(duration: Int, time: Date) -> QuickRoomDetails? {
        var bestDetails: QuickRoomDetails?
        var bestStart: Date = .distantFuture
        
        for room in allRooms {
            let slots = room.availability
                .sorted(by: { $0.startTime < $1.startTime })
                .filter { $0.isAvailable && $0.startTime >= time }
            
            for slot in slots {
                let slotMinutes = Int(slot.endTime.timeIntervalSince(slot.startTime) / 60)
                if slotMinutes == duration {
                    if slot.startTime < bestStart {
                        bestDetails = QuickRoomDetails(slot: slot, room: room)
                        bestStart = slot.startTime
                    }
                }
            }
            
            let count = slots.count
            var i = 0
            while i < count {
                let startSlot = slots[i]
                var sumMinutes = 0
                var lastEnd = startSlot.startTime
                var j = i
                
                while j < count && sumMinutes < duration {
                    let s = slots[j]
                    if s.startTime != lastEnd { break }
                    let minutes = Int(s.endTime.timeIntervalSince(s.startTime) / 60)
                    sumMinutes += minutes
                    lastEnd = s.endTime
                    j += 1
                }
                
                if sumMinutes == duration {
                    let composed = GSRTimeSlot(startTime: startSlot.startTime, endTime: lastEnd, isAvailable: true)
                    if composed.startTime < bestStart {
                        bestDetails = QuickRoomDetails(slot: composed, room: room)
                        bestStart = composed.startTime
                    }
                }
                i += 1
            }
        }
        return bestDetails
    }
    
    @MainActor
    internal func quickBook(location: GSRLocation, duration: Int, time: Date) async throws {
        do {
            try await populateSoonestTimeslot(location: location, duration: duration, time: time)
        } catch {
            print(error)
        }
        
        guard let details = soonestDetails, let location = self.location else {
            return
        }
        
        let timeSlot = details.slot
        let room = details.room
        let booking = GSRBooking(gid: location.gid, startTime: timeSlot.startTime, endTime: timeSlot.endTime, id: room.id, roomName: room.roomName)
        let comparedTime = selectedStartTime ?? Date.now
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: timeSlot.startTime)
        let endString = formatter.string(from: timeSlot.endTime)
        
        let attemptBooking = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                do {
                    try await GSRNetworkManager.makeBooking(for: booking)
                    self.onQuickBookSuccess?(booking)
                } catch {
                    print(error)
                }
            }
        }
        
        if timeSlot.startTime > comparedTime {
            activeAlert = AlertContent(title: "Later Booking Available", message: "\(room.roomName) is available from \(startString) to \(endString).\nWould you still like to book this time?", onAccept: attemptBooking, onCancel: nil)
            return
        }
        
        activeAlert = AlertContent(title: "Booking Available", message: "\(room.roomName) is available from \(startString) to \(endString).\nWould you like to book this time?", onAccept: attemptBooking, onCancel: nil)
    }
}
