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
import Combine


class GSRQuickBook: ObservableObject {
    @ObservedObject var vm: GSRViewModel
    @Published var configuration: QuickBookRequestConfiguration
    
    var numberOfOptions: Int {
        var result = 0
        for duration in self.configuration.durationsAllowed {
            // if i'm looking for a 90-min booking with an end-time of 5pm: that booking would have to start at 3:30
            // note that configuration.endTime is the ending of the window of allowed booking start times.
            let adjustedEnd = self.configuration.endTime.add(minutes: -1 * duration)
            guard let times = durationTimeLookupTable[duration] else { continue }
            result += times.reduce(into: 0) { sum, slot in
                guard slot.key.startTime >= self.configuration.startTime && slot.key.startTime <= adjustedEnd else { return }
                sum += slot.value
            }
        }
        return result
    }
    
    private(set) var durationTimeLookupTable = [Int:[GSRTimeSlot:Int]]()
    
    private(set) var availabilityMemoization: [GSRRoom:[GSRTimeSlot:[Int: Bool]]] { // 3D array: 2D array of roomtimeslots for DP, third dimension is whether a timeslot is available
        didSet {
            // Make sure we minimize in-place modifications to availabilityMemoization to prevent this from re-firing all the time.
            durationTimeLookupTable = Self.getNumericalTimeslotAvailability(from: availabilityMemoization)
        }
    }
    
    static func getNumericalTimeslotAvailability(from avail: [GSRRoom:[GSRTimeSlot:[Int: Bool]]]) -> [Int:[GSRTimeSlot:Int]] {
        var result = [Int:[GSRTimeSlot:Int]]()
        for (_, timeslotDict) in avail {
            for (timeslot, durationDict) in timeslotDict {
                for (duration, isAvailable) in durationDict where isAvailable {
                    result[duration, default: [:]][timeslot, default: 0] += 1
                }
            }
        }
        
        return result
    }
    
    struct RoomTimeslot: Hashable {
        let room: GSRRoom
        let timeslot: GSRTimeSlot
    }
    
    var locationObserver: (AnyCancellable)?
    var dayObserver: (AnyCancellable)?
    
    init(vm: GSRViewModel, configuration: QuickBookRequestConfiguration) {
        self._vm = ObservedObject(wrappedValue: vm)
        self.configuration = configuration
        self.availabilityMemoization = Self.getMemoizedTimeslotAvailability(rooms: vm.roomsAtSelectedLocation, gsrType: vm.selectedLocation?.kind ?? .libcal)
        self.locationObserver = self.vm.$selectedLocation.sink { new in
            let newRooms = self.vm.roomsAtSelectedLocation // THIS COULD BE A RACE CONDITION
            self.configuration = .init(defaultValueFor: new, with: newRooms)
            self.availabilityMemoization = Self.getMemoizedTimeslotAvailability(rooms: newRooms, gsrType: new?.kind ?? .libcal)
        }
        self.dayObserver = self.vm.$selectedDate.sink { new in
            self.configuration = .init(defaultValueFor: vm.selectedLocation, with: vm.roomsAtSelectedLocation, on: new)
        }
    }
    
    private static func getMemoizedTimeslotAvailability(rooms: [GSRRoom], gsrType: GSRLocation.GSRServiceType) -> [GSRRoom:[GSRTimeSlot:[Int: Bool]]]  {
        // Base case
        var newMemo = [GSRRoom:[GSRTimeSlot:[Int: Bool]]]()
        for room in rooms {
            newMemo[room] = [GSRTimeSlot:[Int: Bool]]()
            for timeslot in room.availability {
                newMemo[room]![timeslot] = [30: timeslot.isAvailable]
            }
        }
        
        for duration in Array(stride(from: 30, through: gsrType.maxConsecutiveBookings * 30, by: 30)) {
            for room in rooms {
                var nextTimeslot: GSRTimeSlot? = nil
                for timeslot in room.availability.sorted(by: { $0.startTime > $1.startTime }) {
                    let oldNextTimeslot = nextTimeslot
                    nextTimeslot = timeslot
                    
                    guard let oldNextTimeslot else { continue }
                    if newMemo[room]![timeslot]![duration] != nil { continue }
                    //handle wrapping days
                    //timeslots more than 30 minutes apart should be excluded
                    guard abs(oldNextTimeslot.startTime.minutesFrom(date: timeslot.startTime)) <= 30 else {
                        newMemo[room]![timeslot]![duration] = false
                        nextTimeslot = nil
                        continue
                    }
                    
                    // i.e. we can book a 90-minute reservation if we're available right now and there's a 60-minute reservation 30 minutes from now
                    newMemo[room]![timeslot]![duration] = timeslot.isAvailable && (newMemo[room]![oldNextTimeslot]![duration - 30] ?? false)
                }
            }
        }
        return newMemo
    }
    
    struct QuickBookRequestConfiguration {
        var durationsAllowed: [Int]
        var startTime: Date
        var endTime: Date
        let timeLower: Date
        let timeUpper: Date
        let rooms: [GSRRoom]
        
        init(defaultValueFor location: GSRLocation?, with rooms: [GSRRoom], on day: Date = Date.now) {
            self.durationsAllowed = Array(stride(from: 60, through: (location?.kind.maxConsecutiveBookings ?? 3) * 30, by: 30))
            self.timeLower = (Calendar.current.isDateInToday(day) ? Date.now : day).floorHalfHour
            self.timeUpper = Calendar.current.startOfDay(for: day.addingTimeInterval(60 * 60 * 24)).addingTimeInterval(-1 * 60) // Day at 11:59pm
            self.startTime = self.timeLower
            self.endTime = self.timeUpper
            self.rooms = rooms
        }
    }
}
