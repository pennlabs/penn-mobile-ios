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

@MainActor
class GSRViewModel: ObservableObject {
    @Published var selectedLocation: GSRLocation?
    @Published var roomsAtSelectedLocation: [GSRRoom] = []
    @Published var selectedDate: Date
    @Published var selectedTimeslots: [(GSRRoom, GSRTimeSlot)] = []
    @Published var availableLocations: [GSRLocation] = []
    @Published var datePickerOptions: [Date] = []
    @Published var recentBooking: GSRBooking?
    @Published var isWharton: Bool = false
    @Published var isLoadingAvailability = false
    @Published var showSuccessfulBookingAlert = false
    @Published var sortedStartTime: [Date] = []
    @Published var currentReservations: [GSRReservation] = []
    @Published var settings: GSRViewModel.Settings = Settings()
    @Published var isMapView: Bool = false
    
    @Published var gsrGetLastPulledAvailability: [Int: (availCount: Int, lastRefreshed: Date)] = [:]

    // Quick Book: the user picks a time in the picker, then browses rooms that fit it
    @Published var quickBookPhase: QuickBookPhase = .closed
    @Published var quickBookRequest: [Date] = []    // sorted start times of the slots picked
    @Published var quickBookResults: [QuickBookMatch] = []
    @Published var quickBookIndex: Int = 0

    var hasAvailableBooking: Bool {
        return roomsAtSelectedLocation.contains(where: { !getRelevantAvailability(room: $0).isEmpty })
    }
    
    init() {
        selectedDate = Calendar.nyc.startOfDay(for: Date.now)
        setupDatePickerOptions()
    }
    
    func setupDatePickerOptions() {
        let numDays = selectedLocation?.bookableDays ?? 7 
        let start = Calendar.nyc.startOfDay(for: Date.now)
        datePickerOptions = (0..<numDays).compactMap { Calendar.nyc.date(byAdding: .day, value: $0, to: start) }
        
        if !datePickerOptions.contains(selectedDate), let date = datePickerOptions.first {
            selectedDate = date
        }
    }
    
    @MainActor func fetchInitialState() async throws {
        try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
            group.addTask { @MainActor in
                self.availableLocations = try await GSRNetworkManager.getLocations()
            }
            group.addTask { @MainActor in
                self.isWharton = try await GSRNetworkManager.whartonAllowed()
            }
            group.addTask { @MainActor in
                self.currentReservations = try await GSRNetworkManager.getReservations()
            }
            
            for try await _ in group {}
        }
    }
    
    func resetBooking() {
        withAnimation(.spring(duration: 0.2)) {
            self.selectedTimeslots = []
        }
    }
    
    func handleTimeslotGesture(slot: GSRTimeSlot, room: GSRRoom) throws {
        guard slot.isAvailable else { return }
        // Tapping the grid by hand takes over from Quick Book, but keeps what's selected
        if quickBookPhase != .closed {
            endQuickBook(clearSelection: false)
        }
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
        self.setupDatePickerOptions()
        try await self.updateAvailability()
    }
    
    @MainActor func updateAvailability() async throws {
        self.isLoadingAvailability = true
        self.endQuickBook(clearSelection: true)
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
        self.endQuickBook(clearSelection: true)
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
                self.isWharton = (try? await GSRNetworkManager.whartonAllowed()) ?? false
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

enum QuickBookPhase: Equatable {
    case closed     // nothing open, the toolbar shows "Find me a room"
    case picking    // the timeline picker is open
    case browsing   // a match is selected on the grid, with arrows to move between matches
}

// MARK: Quick Book
extension GSRViewModel {
    var maxQuickBookSlots: Int {
        selectedLocation?.kind.maxConsecutiveBookings ?? 3
    }

    /// The slots shown in the picker: the selected day's slots that haven't ended yet.
    var quickBookPickerSlots: [GSRTimeSlot] {
        getRelevantAvailability().filter { $0.endTime > Date.now }
    }

    var quickBookExactMatches: [QuickBookMatch] {
        guard let start = quickBookRequest.first else { return [] }
        return GSRQuickBookSearch.matches(in: roomsAtSelectedLocation, start: start, slotCount: quickBookRequest.count)
    }

    var quickBookNearbyMatches: [QuickBookMatch] {
        guard let start = quickBookRequest.first else { return [] }
        return GSRQuickBookSearch.nearbyMatches(in: roomsAtSelectedLocation, start: start, slotCount: quickBookRequest.count)
    }

    var currentQuickBookMatch: QuickBookMatch? {
        quickBookResults.indices.contains(quickBookIndex) ? quickBookResults[quickBookIndex] : nil
    }

    /// The time range to draw bold lines around on the grid: the match being shown while browsing,
    /// or the times picked so far while picking.
    var quickBookHighlight: Range<Date>? {
        switch quickBookPhase {
        case .closed:
            return nil
        case .picking:
            guard let first = quickBookRequest.first, let last = quickBookRequest.last else { return nil }
            return first..<last.add(minutes: GSRQuickBookSearch.slotMinutes)
        case .browsing:
            guard let match = currentQuickBookMatch else { return nil }
            return match.start..<match.end
        }
    }

    func startQuickBook() {
        withAnimation(.snappy(duration: 0.2)) {
            selectedTimeslots = []
            quickBookResults = []
            quickBookIndex = 0
            quickBookPhase = .picking
        }
    }

    /// Picker tap rules, matching the grid: picked slots must be back-to-back and at most
    /// `maxQuickBookSlots` long. Tapping an end removes it, tapping elsewhere starts over.
    func toggleQuickBookSlot(_ start: Date) throws {
        var request = quickBookRequest
        let slotLength = TimeInterval(GSRQuickBookSearch.slotMinutes * 60)

        if let first = request.first, let last = request.last, request.contains(start) {
            if start == first || start == last {
                request.removeAll { $0 == start }
            } else {
                request = [start]
            }
        } else if let first = request.first, let last = request.last,
                  start == last.addingTimeInterval(slotLength) || start == first.addingTimeInterval(-slotLength) {
            if request.count >= maxQuickBookSlots {
                throw GSRValidationError.overLimit(limit: maxQuickBookSlots * GSRQuickBookSearch.slotMinutes)
            }
            request.append(start)
            request.sort()
        } else {
            request = [start]
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.snappy(duration: 0.2)) {
            quickBookRequest = request
        }
    }

    /// Searches for the picked time. Uses nearby times when nothing fits exactly.
    /// Returns false (and stays in the picker) when there's nothing to show.
    @discardableResult
    func findQuickBookMatches() -> Bool {
        let exact = quickBookExactMatches
        let results = exact.isEmpty ? quickBookNearbyMatches : exact
        guard !results.isEmpty else { return false }

        quickBookResults = results
        withAnimation(.snappy(duration: 0.2)) {
            quickBookPhase = .browsing
        }
        showQuickBookMatch(at: 0)
        return true
    }

    /// Selects the match at `index` on the grid. Wraps around at either end.
    func showQuickBookMatch(at index: Int) {
        guard !quickBookResults.isEmpty else { return }
        let count = quickBookResults.count
        quickBookIndex = ((index % count) + count) % count
        let match = quickBookResults[quickBookIndex]
        withAnimation(.spring(duration: 0.2)) {
            selectedTimeslots = match.slots.map { (match.room, $0) }
        }
    }

    /// Goes from browsing back to the picker, keeping the picked times.
    func editQuickBookSearch() {
        withAnimation(.snappy(duration: 0.2)) {
            selectedTimeslots = []
            quickBookResults = []
            quickBookIndex = 0
            quickBookPhase = .picking
        }
    }

    func endQuickBook(clearSelection: Bool) {
        withAnimation(.snappy(duration: 0.2)) {
            if clearSelection {
                selectedTimeslots = []
            }
            quickBookRequest = []
            quickBookResults = []
            quickBookIndex = 0
            quickBookPhase = .closed
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
