//
//  GSRViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import Observation
import PennMobileShared

@MainActor
@Observable
final class GSRViewModel {
    typealias Selection = (room: GSRRoom, slot: GSRTimeSlot)
    
    private static let showFullyUnavailableRoomsKey = "gsr.settings.showFullyUnavailableRooms"
    
    private(set) var locations: [GSRLocation] = []
    private(set) var isWharton = false
    private(set) var reservations: [GSRReservation] = []
    private(set) var shareLinks: [String: URL] = [:]
    private(set) var openRoomCounts: [Int: Int] = [:]
    
    private(set) var selectedLocation: GSRLocation?
    private(set) var datePickerOptions: [Date] = []
    private(set) var rooms: [GSRRoom] = []
    private(set) var selectedTimeslots: [Selection] = []
    private(set) var sortedStartTimes: [Date] = []
    private(set) var isLoadingAvailability = false
    
    var selectedDate: Date
    var recentBooking: GSRBooking?
    var message: String?
    var showFullyUnavailableRooms = UserDefaults.standard.bool(forKey: GSRViewModel.showFullyUnavailableRoomsKey) {
        didSet {
            UserDefaults.standard.set(showFullyUnavailableRooms, forKey: Self.showFullyUnavailableRoomsKey)
        }
    }
    
    init() {
        selectedDate = Calendar.nyc.startOfDay(for: .now)
        setupDatePickerOptions()
    }
    
    var displayedRooms: [GSRRoom] {
        rooms.compactMap { room in
            guard showFullyUnavailableRooms || room.availability.contains(where: \.isAvailable) else {
                return nil
            }
            var displayed = room
            displayed.availability = relevantAvailability(for: room)
            return displayed
        }
    }
    
    var headerTimes: [Date] {
        guard let room = rooms.first else { return [] }
        let slots = relevantAvailability(for: room)
        guard let start = slots.first?.startTime else { return [] }
        return [start] + slots.map(\.endTime)
    }
    
    var availableStartTimes: Set<Date> {
        Set(rooms.flatMap { $0.availability.filter(\.isAvailable).map(\.startTime) })
    }
    
    var selectedSlotIDs: Set<UUID> {
        Set(selectedTimeslots.map(\.slot.id))
    }
    
    var hasAvailableBooking: Bool {
        rooms.contains { !relevantAvailability(for: $0).isEmpty }
    }
    
    func fetchInitialState() async {
        do {
            self.locations = try await PennMobileApplication.GSR.GetLocations().execute()
            self.isWharton = try await PennMobileApplication.GSR.GetWhartonStatus().execute().isWharton
        } catch {
            message = error.localizedDescription
        }
        await refreshReservations()
    }
    
    func refreshReservations() async {
        do {
            let reservations = try await PennMobileApplication.GSR.GetReservations().execute()
            self.reservations = reservations
            shareLinks = await Self.fetchShareLinks(for: reservations)
        } catch {
            message = error.localizedDescription
        }
    }
    
    func refreshOpenRoomCounts() async {
        let counts = await Self.fetchOpenRoomCounts(for: locations)
        openRoomCounts.merge(counts) { $1 }
    }
    
    func selectLocation(_ location: GSRLocation) {
        guard location.kind != .wharton || isWharton else {
            message = GSRValidationError.notInWharton.localizedDescription
            return
        }
        selectedLocation = location
        selectedTimeslots = []
        setupDatePickerOptions()
    }
    
    func updateAvailability() async {
        guard let location = selectedLocation else { return }
        let date = selectedDate
        isLoadingAvailability = true
        rooms = []
        selectedTimeslots = []
        sortedStartTimes = []
        
        do {
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
            let availability = try await PennMobileApplication.GSR.GetAvailability(location: location, startDate: date, endDate: endDate).execute().rooms
            guard location == selectedLocation, date == selectedDate else { return }
            
            let (min, max) = availability.getMinMaxDates()
            if let min, let max {
                rooms = availability.map { $0.withMissingTimeslots(minDate: min, maxDate: max) }.sorted()
            }
        } catch {
            guard location == selectedLocation, date == selectedDate else { return }
            message = error.localizedDescription
        }
        isLoadingAvailability = false
    }
    
    func toggleTimeslot(_ slot: GSRTimeSlot, in room: GSRRoom) {
        guard slot.isAvailable else { return }
        
        var newSelected = selectedTimeslots
        let isRemoving = newSelected.contains { $0.room.id == room.id && $0.slot.id == slot.id }
        newSelected.removeAll { $0.room.id == room.id && $0.slot.id == slot.id }
        
        let proposed = isRemoving ? newSelected : newSelected + [(room: room, slot: slot)]
        if (try? Self.validate(proposed)) == nil {
            newSelected = []
        }
        
        let limit = selectedLocation?.kind.maxConsecutiveBookings ?? 3
        if newSelected.count == limit {
            message = GSRValidationError.overLimit(limit: limit * 30).localizedDescription
            return
        }
        
        if !isRemoving {
            newSelected.append((room: room, slot: slot))
        }
        selectedTimeslots = newSelected
    }
    
    func toggleSort(at startTime: Date) {
        guard rooms.hasAvailableAt(startTime) else { return }
        
        if sortedStartTimes.contains(startTime) {
            sortedStartTimes.removeAll { $0 == startTime }
        } else {
            sortedStartTimes.append(startTime)
        }
        
        let sortTimes = sortedStartTimes
        rooms.sort { rm1, rm2 in
            let rm1Avail = sortTimes.allSatisfy { time in rm1.availability.contains { $0.startTime == time && $0.isAvailable } }
            let rm2Avail = sortTimes.allSatisfy { time in rm2.availability.contains { $0.startTime == time && $0.isAvailable } }
            if rm1Avail != rm2Avail {
                return rm1Avail
            }
            return rm1 < rm2
        }
    }
    
    func clearSortFilters() {
        sortedStartTimes = []
        rooms.sort()
    }
    
    func book() async {
        guard let location = selectedLocation, !selectedTimeslots.isEmpty else { return }
        
        do {
            guard location.kind != .wharton || isWharton else {
                throw GSRValidationError.notInWharton
            }
            try Self.validate(selectedTimeslots)
            
            let sorted = selectedTimeslots.sorted { $0.slot.startTime < $1.slot.startTime }
            let first = sorted.first!
            let booking = GSRBooking(gid: location.gid, startTime: first.slot.startTime, endTime: sorted.last!.slot.endTime, id: first.room.id, roomName: first.room.roomName)
            
            try await PennMobileApplication.GSR.MakeBooking(booking: booking).execute()
            recentBooking = booking
        } catch {
            message = error.localizedDescription
        }
        
        await refreshReservations()
        await updateAvailability()
    }
    
    func cancel(_ reservation: GSRReservation) async {
        do {
            try await PennMobileApplication.GSR.CancelReservation(bookingId: reservation.bookingId).execute()
        } catch {
            message = "Unable to delete this reservation. Is it currently in progress?"
        }
        await refreshReservations()
    }
    
    func addToCalendar(_ reservation: GSRReservation) async {
        do {
            try await CalendarHelper.addToCalendar(
                title: "GSR Booking: \(reservation.gsr.name) \(reservation.roomName)",
                location: reservation.gsr.name,
                start: reservation.start,
                end: reservation.end
            )
            message = "Added to calendar!"
        } catch CalendarError.accessDenied {
            message = "Calendar access denied. Please enable it in Settings."
        } catch {
            message = "Failed to add event to calendar."
        }
    }
    
    private func setupDatePickerOptions() {
        let start = Calendar.nyc.startOfDay(for: .now)
        datePickerOptions = (0..<(selectedLocation?.bookableDays ?? 7)).compactMap {
            Calendar.nyc.date(byAdding: .day, value: $0, to: start)
        }
        
        if !datePickerOptions.contains(selectedDate), let date = datePickerOptions.first {
            selectedDate = date
        }
    }
    
    private func relevantAvailability(for room: GSRRoom) -> [GSRTimeSlot] {
        room.availability.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    private nonisolated static func validate(_ slots: [Selection]) throws {
        guard let first = slots.first else { return }
        
        guard slots.allSatisfy({ $0.room.id == first.room.id }) else {
            throw GSRValidationError.differentRooms
        }
        
        let sorted = slots.sorted { $0.slot.startTime < $1.slot.startTime }
        for (current, next) in zip(sorted, sorted.dropFirst()) where current.slot.endTime != next.slot.startTime {
            throw GSRValidationError.splitTimeSlots
        }
        
        if slots.contains(where: { Date.now.localTime > $0.slot.endTime }) {
            throw GSRValidationError.bookingInPast
        }
    }
    
    private nonisolated static func fetchShareLinks(for reservations: [GSRReservation]) async -> [String: URL] {
        await withTaskGroup(of: (String, URL?).self) { group in
            for reservation in reservations {
                group.addTask {
                    let code = try? await PennMobileApplication.GSR.CreateShareCode(bookingId: reservation.bookingId).execute()
                    return (reservation.bookingId, code.flatMap { URL(string: $0.link) })
                }
            }
            
            var links = [String: URL]()
            for await (bookingId, url) in group {
                links[bookingId] = url
            }
            return links
        }
    }
    
    private nonisolated static func fetchOpenRoomCounts(for locations: [GSRLocation]) async -> [Int: Int] {
        await withTaskGroup(of: (Int, Int?).self) { group in
            for location in locations {
                group.addTask {
                    let rooms = try? await PennMobileApplication.GSR.GetAvailability(location: location, startDate: .now, endDate: .now).execute().rooms
                    return (location.gid, rooms.map(openRoomCount))
                }
            }
            
            var counts = [Int: Int]()
            for await (gid, count) in group {
                counts[gid] = count
            }
            return counts
        }
    }
    
    private nonisolated static func openRoomCount(in rooms: [GSRRoom]) -> Int {
        let cutoff = Date.now.addingTimeInterval(60)
        return rooms.filter { room in
            guard let firstSlot = room.availability.min(by: { $0.startTime < $1.startTime }) else { return false }
            return firstSlot.startTime <= cutoff
        }.count
    }
}
