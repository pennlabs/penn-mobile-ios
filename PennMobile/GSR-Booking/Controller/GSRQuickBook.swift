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

class GSRQuickBook {
    
    fileprivate var location: GSRLocation?
    fileprivate var soonestDetails: QuickRoomDetails?
    fileprivate var allRooms: [GSRRoom] = []
    
    fileprivate struct QuickRoomDetails {
        var slot: GSRTimeSlot
        var room: GSRRoom
    }
    
    var onQuickBookSuccess: ((GSRBooking) -> Void)?

    @MainActor
    internal func populateSoonestTimeslot(location: GSRLocation, duration: Int, time: Date) async throws{
        self.location = location
        let avail = try await GSRNetworkManager.getAvailability(for: location, startDate: Date.now, endDate: Date.now)
        self.allRooms = avail
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
}

extension GSRQuickBook: GSRBookable {
    func showAlert(withMsg: String, title: String, completion: (() -> Void)?) {
        return
    }
    
    func showOption(withMsg: String, title: String, onAccept: (() -> Void)?, onCancel: (() -> Void)?) {
        return
    }
    
    @MainActor internal func quickBook() {
        guard let details = soonestDetails, let location = self.location else {
            return
        }

        let timeSlot: GSRTimeSlot = details.slot
        let timeRoom: GSRRoom = details.room
        let booking = GSRBooking(gid: location.gid, startTime: timeSlot.startTime, endTime: timeSlot.endTime, id: timeRoom.id, roomName: timeRoom.roomName)

        if let onQuickBookSuccess = onQuickBookSuccess {
            Task { @MainActor in
                do {
                    try await GSRNetworkManager.makeBooking(for: booking)
                    onQuickBookSuccess(booking)
                } catch {
                    print(error)
                }
            }
        }
    }
}
