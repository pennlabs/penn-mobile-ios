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
    @Published var shareLinks: [String: URL] = [:]
    @Published var settings: GSRViewModel.Settings = Settings()
    @Published var isMapView: Bool = false

    @Published var gsrGetLastPulledAvailability: [Int: (availCount: Int, lastRefreshed: Date)] = [:]

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

    func fetchInitialState() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                self.availableLocations = await PennMobileApplication.GSR.GetLocations().execute().unwrap() ?? []
            }
            group.addTask { @MainActor in
                self.isWharton = await PennMobileApplication.GSR.GetWhartonStatus().execute().unwrap()?.isWharton ?? false
            }
            group.addTask { @MainActor in
                await self.refreshReservations()
            }
        }
    }

    func refreshReservations() async {
        guard let reservations = await PennMobileApplication.GSR.GetReservations().execute().unwrap() else { return }
        self.currentReservations = reservations
        self.shareLinks = await Self.fetchShareLinks(for: reservations)
    }

    func cancelReservation(_ reservation: GSRReservation) async {
        withAnimation {
            self.currentReservations.removeAll { $0.bookingId == reservation.bookingId }
        }
        await PennMobileApplication.GSR.CancelReservation(bookingId: reservation.bookingId).execute()
        await refreshReservations()
    }

    // Only reloads a location's open room count once per refresh interval
    func refreshOpenRoomCounts(refreshInterval: TimeInterval = 90) async {
        let now = Date()
        let stale = availableLocations.filter { location in
            guard let last = gsrGetLastPulledAvailability[location.gid]?.lastRefreshed else { return true }
            return now.timeIntervalSince(last) > refreshInterval
        }

        for (gid, count) in await Self.fetchOpenRoomCounts(for: stale) {
            gsrGetLastPulledAvailability[gid] = (availCount: count, lastRefreshed: now)
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

    func setLocation(to location: GSRLocation) async throws {
        if location.kind == .wharton && !self.isWharton {
            throw GSRValidationError.notInWharton
        }
        self.selectedLocation = location
        self.resetBooking()
        self.setupDatePickerOptions()
        await self.updateAvailability()
    }

    func updateAvailability() async {
        self.isLoadingAvailability = true
        self.roomsAtSelectedLocation = []
        self.selectedTimeslots = []
        self.sortedStartTime = []

        guard let loc = self.selectedLocation else {
            self.isLoadingAvailability = false
            return
        }

        let date = self.selectedDate
        let avail = await PennMobileApplication.GSR.GetAvailability(location: loc, startDate: date, endDate: Calendar.current.date(byAdding: .day, value: 1, to: date)!).execute().unwrap()?.rooms ?? []

        // A newer request has started since this one was made
        guard loc == self.selectedLocation, date == self.selectedDate else { return }

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

    func book() async throws {
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

        // Failures are surfaced by the endpoint's toast
        guard case .success = await PennMobileApplication.GSR.MakeBooking(booking: booking).execute() else { return }
        // This recentBooking field is for a future implementation of a GSR Booking Detail View
        self.recentBooking = booking
        await self.refreshReservations()
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
        Task {
            self.isWharton = await PennMobileApplication.GSR.GetWhartonStatus().execute(shouldSilentlyFail: true).unwrap()?.isWharton ?? false
        }
    }

    private nonisolated static func fetchShareLinks(for reservations: [GSRReservation]) async -> [String: URL] {
        await withTaskGroup(of: (String, URL?).self) { group in
            for reservation in reservations {
                group.addTask {
                    let code = await PennMobileApplication.GSR.CreateShareCode(bookingId: reservation.bookingId)
                        .execute(shouldSilentlyFail: true)
                        .unwrap()
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
                    let rooms = await PennMobileApplication.GSR.GetAvailability(location: location, startDate: .now, endDate: .now)
                        .execute(shouldSilentlyFail: true)
                        .unwrap()?
                        .rooms
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
