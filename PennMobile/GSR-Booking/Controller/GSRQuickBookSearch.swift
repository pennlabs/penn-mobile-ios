//
//  GSRQuickBookSearch.swift
//  PennMobile
//
//  Created by Laura Chen on 10/3/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

struct QuickBookMatch: Hashable, Identifiable {
    let room: GSRRoom
    let slots: [GSRTimeSlot]
    let offsetMinutes: Int

    var id: String { "\(room.id)-\(start.timeIntervalSince1970)" }
    var start: Date { slots.first!.startTime }
    var end: Date { slots.last!.endTime }
    var isExact: Bool { offsetMinutes == 0 }
}

enum GSRQuickBookSearch {
    static let slotMinutes = 30

    // How many rooms are free for the 30-minute slot starting at "start".
    static func openCount(at start: Date, in rooms: [GSRRoom]) -> Int {
        rooms.filter { room in
            room.availability.contains { $0.startTime == start && $0.isAvailable }
        }.count
    }

    /// The `slotCount` back-to-back free slots in `room` starting at `start`, or nil if any of
    /// them is taken, missing, not consecutive, or already over.
    static func freeRun(in room: GSRRoom, start: Date, slotCount: Int, now: Date) -> [GSRTimeSlot]? {
        guard slotCount > 0,
              let first = room.availability.firstIndex(where: { $0.startTime == start }),
              first + slotCount <= room.availability.count else {
            return nil
        }

        let run = Array(room.availability[first..<(first + slotCount)])
        for (i, slot) in run.enumerated() {
            guard slot.isAvailable, slot.endTime > now else { return nil }
            if i > 0 && run[i - 1].endTime != slot.startTime { return nil }
        }
        return run
    }

    /// Every room that is free for the whole request, in the order `rooms` is given.
    static func matches(in rooms: [GSRRoom], start: Date, slotCount: Int, now: Date = .now) -> [QuickBookMatch] {
        matches(in: rooms, start: start, slotCount: slotCount, offsetMinutes: 0, now: now)
    }

    /// Matches for the same length of booking, shifted up to `maxOffsetSlots` slots earlier or later.
    /// Closest times come first, and earlier comes before later at the same distance.
    static func nearbyMatches(in rooms: [GSRRoom], start: Date, slotCount: Int,
                              maxOffsetSlots: Int = 2, now: Date = .now) -> [QuickBookMatch] {
        guard maxOffsetSlots > 0 else { return [] }
        var result = [QuickBookMatch]()
        for step in 1...maxOffsetSlots {
            for direction in [-1, 1] {
                let offset = direction * step * slotMinutes
                result += matches(in: rooms, start: start.addingTimeInterval(TimeInterval(offset * 60)),
                                  slotCount: slotCount, offsetMinutes: offset, now: now)
            }
        }
        return result
    }

    private static func matches(in rooms: [GSRRoom], start: Date, slotCount: Int,
                                offsetMinutes: Int, now: Date) -> [QuickBookMatch] {
        rooms.compactMap { room in
            freeRun(in: room, start: start, slotCount: slotCount, now: now).map {
                QuickBookMatch(room: room, slots: $0, offsetMinutes: offsetMinutes)
            }
        }
    }
}
