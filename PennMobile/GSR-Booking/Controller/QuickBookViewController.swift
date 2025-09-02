//
//  QuickBookViewController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 2/23/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

class QuickBookViewController: UIViewController {
    
    fileprivate var location: GSRLocation!
    fileprivate var soonestDetails: (slot: GSRTimeSlot, room: GSRRoom)?
    fileprivate var soonestStartTimeString: String!
    fileprivate var soonestEndTimeString: String!
    fileprivate var allRooms: [GSRRoom]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func setupQuickBooking(location: GSRLocation, completion: @escaping () -> Void) {
        self.location = location
        if let best = getSoonestTimeSlot() {
            self.soonestDetails = best
            completion()
        }
        let group = DispatchGroup()
        var foundAvailableRoom = false
        
        completion()
        
//        GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: nil) { [self] result in
//            defer {
//                group.leave()
//            }
//            
//            switch result {
//            case .success(let rooms):
//                if !rooms.isEmpty {
//                    self.allRooms = rooms
//                    self.getSoonestTimeSlot()
//                    foundAvailableRoom = true
//                }
//            case .failure:
//                present(toast: .apiError)
//            }
//        }
//        if !foundAvailableRoom && location == self.locations.last {
//            present(toast: .apiError)
//        }
//        group.notify(queue: DispatchQueue.main) {
//            if foundAvailableRoom {
//                completion()
//                self.setupSubmitAlert(location: location)
//            } else {
//                self.present(toast: .apiError)
//            }
//        }
    }
    
    private func getSoonestTimeSlot() -> (slot: GSRTimeSlot, room: GSRRoom)? {
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
    @objc internal func quickBook() {
        if !Account.isLoggedIn {
            self.showAlert(withMsg: "You are not logged in!", title: "Error", completion: {self.navigationController?.popViewController(animated: true)})
        } else {
            var timeSlot :GSRTimeSlot = soonestDetails!.slot
            var timeRoom :GSRRoom = soonestDetails!.room
            submitBooking(for: GSRBooking(gid: location.gid, startTime: timeSlot.startTime, endTime: timeSlot.endTime, id: timeRoom.id, roomName: timeRoom.roomName))
        }
    }
}
