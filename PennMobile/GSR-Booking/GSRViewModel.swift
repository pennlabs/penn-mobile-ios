//
//  GSRViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import PennMobileShared

class GSRViewModel: ObservableObject {
    @Published var selectedLocation: GSRLocation? {
        didSet {
            onLocationChange(oldLocation: oldValue, newLocation: newValue)
        }
    }
    @Published var roomsAtSelectedLocation: [GSRRoom] = []
    @Published var selectedDate: Date?
    @Published var selectedTimeslots: [(GSRRoom, GSRTimeSlot)] = []
    
    
    
    func resetBooking() {
        selectedTimeslots = []
    }
    
    func handleTimeslotGesture(slot: GSRTimeSlot, room: GSRRoom) throws {
        guard slot.isAvailable else { return }
        
        // 90 minute check assumes 30 minute bookings
        if selectedTimeslots.count == 3 {
            throw GSRValidationError.over90Minutes
        }
        
        let proposedTimeslots = selectedTimeslots + [(room, slot)]
        do {
            try validateSelectedTimeslots(proposedTimeslots)
        } catch {
            resetBooking()
        }
        
        selectedTimeslots.append((room, slot))
    }
    
    private func validateSelectedTimeslots(_ slots: [(GSRRoom, GSRTimeSlot)]) throws {
        // Same room check
        guard let (room, slot) = slots.first else { return }
        let sameRoom: Result<GSRRoom, GSRValidationError> = slots.reduce(.success(room)) { (result, slot) in
            guard case .success(let room) = result else {
                return result
            }
            
            if room == slot.0 {
                return .success(room)
            } else {
                return .failure(GSRValidationError.differentRooms)
            }
        }
        
        if case .failure(let failure) = sameRoom {
            throw failure
        }
        
        // Concurrency check
        let sorted = slots.sorted(by: { $0.1.startTime < $1.1.startTime })
        
        for (i, slot) in sorted.enumerated() {
            if i + 1 == sorted.count { break }
            let next = sorted[i + 1]
            if slot.1.endTime != next.1.startTime {
                throw GSRValidationError.splitTimeSlots
            }
        }
        
        // Past check
        if !slots.filter({ Date.now.localTime > $0.1.endTime }).isEmpty {
            throw GSRValidationError.bookingInPast
        }
        
    }
    
    private func onLocationChange(oldLocation: GSRLocation?, newLocation: GSRLocation?) {
        resetBooking()
        guard let newLocation else { return }
        DispatchQueue.main.async {
            GSRNetworkManager.instance.getAvailability(lid: newLocation.lid, gid: newLocation.gid) { res in
                
            }
        }
    }
    
    enum GSRValidationError: Error, LocalizedError {
        case over90Minutes
        case differentRooms
        case splitTimeSlots
        case bookingInPast
        
        var errorDescription: String? {
            switch self {
            case .over90Minutes:
                return "You cannot create a booking for more than 90 minutes."
            case .differentRooms:
                return "You cannot book two separate rooms at the same time."
            case .splitTimeSlots:
                return "You must create a single, concurrent reservation."
            case .bookingInPast:
                return "This timeslot is already elapsed."
            }
        }
    }
}
