//
//  QuickBookViewController.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 2/23/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

class QuickBookViewController: UIViewController, ShowsAlert {
    
    var locations: [GSRLocation] = GSRLocationModel.shared.getLocations()
    fileprivate var prefList: [GSRLocation] = []
    fileprivate var location: GSRLocation!
    
    fileprivate var soonestStartTimeString: String!
    fileprivate var soonestEndTimeString: String!
    fileprivate var soonestTimeSlot: GSRTimeSlot!
    fileprivate var soonestRoom: GSRRoom!
    fileprivate var min: Date! = Date.distantFuture
    
    fileprivate var allRooms: [GSRRoom]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func setupSubmitAlert(location: GSRLocation){
        let alert = UIAlertController(title: "Quick Book GSR", message: """
            Soonest available GSR:
            Time Slot: \(soonestStartTimeString!) to \(soonestEndTimeString!)
            Room: \(soonestRoom.roomName)
            Location: \(location.name)
            
            Quickly book the soonest available room in any location on campus.
            """, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(cancelAction)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { _ in
            self.quickBook()
        }
        
        alert.addAction(acceptAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    internal func setupQuickBooking(location: GSRLocation, completion: @escaping () -> Void) {
        self.location = location
        let group = DispatchGroup()
        var foundAvailableRoom = false
        
        GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: nil) { [self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let rooms):
                if !rooms.isEmpty {
                    self.allRooms = rooms
                    self.getSoonestTimeSlot()
                    foundAvailableRoom = true
                }
            case .failure:
                present(toast: .apiError)
            }
        }
        if !foundAvailableRoom && location == self.locations.last {
            present(toast: .apiError)
        }
        group.notify(queue: DispatchQueue.main) {
            if foundAvailableRoom {
                completion()
                self.setupSubmitAlert(location: location)
            } else {
                self.present(toast: .apiError)
            }
        }
    }
    
    private func getSoonestTimeSlot() {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        for room in allRooms {
            guard let availability = room.availability.first(where: { $0.startTime >= Date() }) else {
                continue
            }
            let startTime = availability.startTime
            
            if startTime < min {
                min = startTime
                soonestStartTimeString = formatter.string(from: startTime)
                soonestEndTimeString = formatter.string(from: availability.endTime)
                soonestTimeSlot = availability
                soonestRoom = room
            }
        }
    }
}

extension QuickBookViewController: GSRBookable {
    @objc internal func quickBook() {
        if !Account.isLoggedIn {
            self.showAlert(withMsg: "You are not logged in!", title: "Error", completion: {self.navigationController?.popViewController(animated: true)})
        } else {
            submitBooking(for: GSRBooking(gid: location.gid, startTime: soonestTimeSlot.startTime, endTime: soonestTimeSlot.endTime, id: soonestRoom.id, roomName: soonestRoom.roomName))
        }
    }
}
