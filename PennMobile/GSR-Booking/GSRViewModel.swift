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


extension GSRViewModel {
    struct Settings: Equatable {
        static func == (lhs: GSRViewModel.Settings, rhs: GSRViewModel.Settings) -> Bool {
            lhs.shouldShowFullyUnavailableRooms == rhs.shouldShowFullyUnavailableRooms
            && lhs.shouldShowLegacyUI == rhs.shouldShowLegacyUI
        }
        
        // Should the user be shown rooms that have no availability
        @AppStorage("gsr.settings.showFullyUnavailableRooms") var shouldShowFullyUnavailableRooms: Bool = false
        @AppStorage("gsr.settings.showLegacyUI") var shouldShowLegacyUI: Bool = false
    }
}

class GSRViewModel: ObservableObject {
    @Published var selectedLocation: GSRLocation?
    @Published var roomsAtSelectedLocation: [GSRRoom] = []
    @Published var selectedDate: Date
    @Published var selectedTimeslots: [(GSRRoom, GSRTimeSlot)] = []
    @Published var availableLocations: [GSRLocation] = []
    @Published var datePickerOptions: [Date]
    @Published var recentBooking: GSRBooking?
    @Published var isWharton: Bool = false
    @Published var isLoadingAvailability = false
    @Published var showSuccessfulBookingAlert = false
    @Published var sortedStartTime: [Date] = []
    @Published var currentReservations: [GSRReservation] = []
    @Published var settings: GSRViewModel.Settings = Settings()
    @Published var isMapView: Bool = false
    @Published var shouldShowRefreshIcon: Bool = false
    
    var hasAvailableBooking: Bool {
        return roomsAtSelectedLocation.contains(where: { !getRelevantAvailability(room: $0).isEmpty })
    }
    
    init() {
        let options = (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date.now) }
        datePickerOptions = options
        selectedDate = options.first!
        Task(operation: self.getInitialState)
    }
    
    @MainActor func getInitialState() async {
        do {
            self.availableLocations = try await GSRNetworkManager.getLocations()
            self.isWharton = try await GSRNetworkManager.whartonAllowed()
            self.currentReservations = try await GSRNetworkManager.getReservations()
            self.shouldShowRefreshIcon = false
        } catch {
            if let authError = error as? NetworkingError, authError.rawValue == NetworkingError.authenticationError.rawValue {
                ToastView.sharedCallback?(.init(message: "Unable to fetch data due to invalid login state. Try to log out and log back into Penn Mobile."))
            } else {
                ToastView.sharedCallback?(.init(message: "Unable to fetch GSR data."))
            }
            self.shouldShowRefreshIcon = true
        }
    }
    
    func resetBooking() {
        withAnimation(.spring(duration: 0.2)) {
            self.selectedTimeslots = []
        }
    }
    
    func handleTimeslotGesture(slot: GSRTimeSlot, room: GSRRoom) throws {
        guard slot.isAvailable else { return }
        // Consider a timeslot gesture as a transaction, of sorts
        // Regardless of if they're adding or removing we have to validate the transaction before
        // committing it to the actual state `self.selectedTimeslots`
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
        
        // This case is handled separately of the validate function, because it shouldn't reset the booking,
        // it should instead have a toast appear.
        if newSelected.count == self.selectedLocation?.kind.maxConsecutiveBookings ?? 3 {
            throw GSRValidationError.overLimit(limit: (self.selectedLocation?.kind.maxConsecutiveBookings ?? 3) * 30)
        }
        if adding {
            newSelected.append((room, slot))
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        withAnimation(.spring(duration: 0.2)) {
            self.selectedTimeslots = newSelected
        }
    }
    
    func clearSortedFilters() {
        self.sortedStartTime.removeAll()
        self.roomsAtSelectedLocation.sort()
    }
    
    func handleSortAction(to startTime: Date) {
        guard self.roomsAtSelectedLocation.hasAvailableAt(startTime) else {
            return
        }
        
        if self.sortedStartTime.contains(where: { $0 == startTime }) {
            self.sortedStartTime.removeAll(where: { $0 == startTime })
        } else {
            self.sortedStartTime.append(startTime)
        }
        
        self.roomsAtSelectedLocation.sort(by: { rm1, rm2 in
            var rm1Avail = true
            var rm2Avail = true
            for sortDate in self.sortedStartTime {
                rm1Avail = rm1Avail && rm1.availability.contains(where: { $0.startTime == sortDate && $0.isAvailable })
                rm2Avail = rm2Avail && rm2.availability.contains(where: { $0.startTime == sortDate && $0.isAvailable })
            }
            if rm1Avail && !rm2Avail { return true }
            if !rm1Avail && rm2Avail { return false }
            
            return rm1 < rm2
        })
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
    
    @MainActor func setLocation(to location: GSRLocation) async throws {
        if location.kind == .wharton && !self.isWharton {
            throw GSRValidationError.notInWharton
        }
        self.selectedLocation = location
        self.resetBooking()
        try await self.updateAvailability()
    }
    
    @MainActor func updateAvailability() async throws {
        self.isLoadingAvailability = true
        self.roomsAtSelectedLocation = []
        self.selectedTimeslots = []
        self.sortedStartTime = []
        
        guard let loc = self.selectedLocation else {
            self.isLoadingAvailability = false
            return
        }
        
        let avail = try await GSRNetworkManager.getAvailability(for: loc, startDate: self.selectedDate, endDate: Calendar.current.date(byAdding: .day, value: 1, to: self.selectedDate)!)
        
        

        let (min, max) = avail.getMinMaxDates()
        
        guard let min, let max else {
            self.isLoadingAvailability = false
            return
        }
        
        self.roomsAtSelectedLocation = avail.map {
            return $0.withMissingTimeslots(minDate: min, maxDate: max)
        }.sorted()
        
        self.isLoadingAvailability = false
    }
    
    @MainActor func book() async throws {
        guard let loc = self.selectedLocation, !self.selectedTimeslots.isEmpty else { return }
        if loc.kind == .wharton && !self.isWharton {
            throw GSRValidationError.notInWharton
        }
        try self.validateSelectedTimeslots(self.selectedTimeslots)
        
        let sorted = self.selectedTimeslots.sorted { el1, el2 in
            return el1.1.startTime < el2.1.startTime
        }
        let room = sorted.first!.0
        let start = sorted.first!.1.startTime
        let end = sorted.last!.1.endTime
        let booking = GSRBooking(gid: loc.gid, startTime: start, endTime: end, id: room.id, roomName: room.roomName)
        
        try await GSRNetworkManager.makeBooking(for: booking)
        // This recentBooking field is for a future implementation of a GSR Booking Detail View
        self.recentBooking = booking
        self.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
        self.showSuccessfulBookingAlert = true
        self.selectedTimeslots.removeAll()
        self.clearSortedFilters()
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
                do {
                    self.isWharton = try await GSRNetworkManager.whartonAllowed()
                } catch {
                    self.isWharton = false
                    ToastView.sharedCallback?(.init(message: "Unable to fetch Wharton status. Please try again."))
                }
            }
        }
    }
    
    enum GSRValidationError: Error, LocalizedError {
        case overLimit(limit: Int)
        case differentRooms
        case splitTimeSlots
        case bookingInPast
        case notInWharton
        
        var errorDescription: String? {
            switch self {
            case .overLimit(let limit):
                return "You cannot create a booking for more than \(limit) minutes at this location."
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

extension Array where Element == GSRLocation {
    var standardGSRSort: [GSRLocation] {
        let sort = self.sorted { el1, el2 in
            // Appease Wharton Board
            if el1.name == "Huntsman" { return true }
            
            if el1.kind == .wharton && el2.kind == .libcal {
                return true
            }
            
            return el1.name < el2.name
        }
        return sort
    }
}

extension Date {
    var gsrTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        return formatter.string(from: self)
    }
    
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
    
    var floorHalfHour: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        
        var roundedMinutes = (components.minute! / 30) * 30
        
        return calendar.date(bySettingHour: components.hour!, minute: roundedMinutes, second: 0, of: self)!
    }
}
