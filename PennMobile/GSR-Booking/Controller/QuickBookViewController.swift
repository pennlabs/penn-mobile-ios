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

class QuickBookViewController: UIViewController {
    
    fileprivate var location: GSRLocation!
    fileprivate var soonestDetails: (slot: GSRTimeSlot, room: GSRRoom)?
    fileprivate var soonestStartTimeString: String!
    fileprivate var soonestEndTimeString: String!
    fileprivate var allRooms: [GSRRoom]!
    
    // Callbacks to allow SwiftUI to react to quick book results
    var onQuickBookSuccess: ((GSRBooking) -> Void)?
    var onQuickBookFailure: ((Error) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @MainActor
    internal func setupQuickBooking(location: GSRLocation, duration: Int, time: Date) async throws{
        self.location = location
        
        do {
            let avail = try await GSRNetworkManager.getAvailability(for: location, startDate: Date.now, endDate: Date.now)
            self.allRooms = avail
            soonestDetails = getSoonestTimeSlot(duration: duration, time: time)
        } catch {
            print(error)
        }
    }
    
    private func getSoonestTimeSlot(duration: Int, time: Date) -> (slot: GSRTimeSlot, room: GSRRoom)? {
        let formatter = DateFormatter()
        var current: (slot: GSRTimeSlot, room: GSRRoom)?
        var start : Date! = .distantFuture
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        for room in allRooms {
            guard let availability = room.availability.first(where: { $0.startTime >= Date() }) else {
                continue
            }
            
            if availability.startTime < start {
                current = (availability, room)
                start = availability.startTime
                soonestStartTimeString = formatter.string(from: availability.startTime)
                soonestEndTimeString = formatter.string(from: availability.endTime)
            }
        }

        return current
    }
}

extension QuickBookViewController: GSRBookable {
    internal func quickBook() {
        if !Account.isLoggedIn {
            self.showAlert(withMsg: "You are not logged in!", title: "Error", completion: { self.navigationController?.popViewController(animated: true) })
            return
        }
        guard let details = soonestDetails, let location = self.location else {
            self.showAlert(withMsg: "No available time slots found.", title: "Unavailable", completion: nil)
            return
        }

        let timeSlot: GSRTimeSlot = details.slot
        let timeRoom: GSRRoom = details.room
        let booking = GSRBooking(gid: location.gid, startTime: timeSlot.startTime, endTime: timeSlot.endTime, id: timeRoom.id, roomName: timeRoom.roomName)

        // If a SwiftUI callback is provided, handle booking with async API and inform the caller.
        if let onQuickBookSuccess = onQuickBookSuccess {
            Task { @MainActor in
                do {
                    try await GSRNetworkManager.makeBooking(for: booking)
                    onQuickBookSuccess(booking)
                } catch {
                    if let onQuickBookFailure = self.onQuickBookFailure {
                        onQuickBookFailure(error)
                    } else {
                        self.showAlert(withMsg: error.localizedDescription, title: "Booking Failed", completion: nil)
                    }
                }
            }
        } else {
            // Fallback to legacy flow if no callback is set
            submitBooking(for: booking)
        }
    }
}
