//
//  GSRViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import PennMobileShared

class GSRViewModel: ObservableObject {
    @Published var selectedLocation: GSRLocation?
    @Published var roomsAtSelectedLocation: [GSRRoom] = []
    @Published var selectedDate: Date
    @Published var selectedTimeslots: [(GSRRoom, GSRTimeSlot)] = []
    @Published var availableLocations: [GSRLocation] = []
    @Published var datePickerOptions: [Date]
    @Published var isWharton: Bool = false
    
    init() {
        let options = (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date.now) }
        datePickerOptions = options
        selectedDate = options.first!
        DispatchQueue.main.async {
            Task {
                self.availableLocations = (try? await GSRNetworkManager.getLocations()) ?? []
                self.isWharton = (try? await GSRNetworkManager.whartonAllowed()) ?? false
                return
            }
        }
        
    }
    
    
    
    func resetBooking() {
        withAnimation(.spring(duration: 0.2)) {
            self.selectedTimeslots = []
        }
    }
    
    func handleTimeslotGesture(slot: GSRTimeSlot, room: GSRRoom) throws {
        guard slot.isAvailable else { return }
        var newSelected = selectedTimeslots
        var adding: Bool = true
        if newSelected.contains(where: {$0.0 == room && $0.1 == slot}) {
            newSelected.removeAll(where: {$0.0 == room && $0.1 == slot})
            adding = false
        }
 
        let proposedTimeslots = newSelected + (adding ? [(room, slot)] : [])
        do {
            try validateSelectedTimeslots(proposedTimeslots)
        } catch {
            newSelected = []
        }
        
        // 90 minute check assumes 30 minute bookings
        if newSelected.count == 3 {
            throw GSRValidationError.over90Minutes
        }
        
        if adding {
            newSelected.append((room, slot))
        }
        withAnimation(.spring(duration: 0.2)) {
            self.selectedTimeslots = newSelected
        }
        
    }
    
    private func validateSelectedTimeslots(_ slots: [(GSRRoom, GSRTimeSlot)]) throws {
        // Same room check
        guard let (room, _) = slots.first else { return }
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
    
    func setLocation(to location: GSRLocation) throws {
        DispatchQueue.main.async {
            self.resetBooking()
            Task {
                if location.kind == .wharton && !self.isWharton {
                    throw GSRValidationError.notInWharton
                }
                
                let unfilteredLoc = try await GSRNetworkManager.getAvailability(for: location, startDate: self.datePickerOptions.first!, endDate: self.datePickerOptions.last!)
                let nonEmptyRooms = unfilteredLoc.filter {
                    !$0.availability.isEmpty
                }

                let (min, max) = nonEmptyRooms.getMinMaxDates()
                self.roomsAtSelectedLocation = nonEmptyRooms.map {
                    if let min, let max {
                        return $0.withMissingTimeslots(minDate: min, maxDate: max)
                    } else {
                        let times = $0.availability.sorted(by: {$0.startTime < $1.startTime})
                        return $0.withMissingTimeslots(minDate: times.first!.startTime, maxDate: times.last!.startTime)
                    }
                }
                self.selectedLocation = location
            }
        }
    }
    
    func getRelevantAvailability(room: GSRRoom? = nil) -> [GSRTimeSlot] {
        guard let currRoom = room ?? self.roomsAtSelectedLocation.first else { return [] }
        return currRoom.availability.filter {
            let cal = Calendar.current
            return cal.isDate($0.startTime, inSameDayAs: self.selectedDate)
        }
    }
    
    func checkWhartonStatus() {
        DispatchQueue.main.async {
            Task {
                self.isWharton = (try? await GSRNetworkManager.whartonAllowed()) ?? false
            }
        }
    }
    
    enum GSRValidationError: Error, LocalizedError {
        case over90Minutes
        case differentRooms
        case splitTimeSlots
        case bookingInPast
        case notInWharton
        
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
            case .notInWharton:
                return "You must be a Wharton student to view this location."
            }
        }
    }
}
