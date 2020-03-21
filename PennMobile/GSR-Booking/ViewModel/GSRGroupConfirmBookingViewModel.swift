//
//  GSRGroupConfirmBookingViewModel.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 3/13/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

protocol GSRGroupConfirmBookingViewModelDelegate {
    func reloadData()
}
class GSRGroupConfirmBookingViewModel: NSObject {
    fileprivate var groupBooking: GSRGroupBooking!
    var delegate: GSRGroupConfirmBookingViewModelDelegate?
    
    init(groupBooking: GSRGroupBooking) {
        self.groupBooking = groupBooking
    }
}

// MARK: - UITableViewDataSource
extension GSRGroupConfirmBookingViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GroupBookingConfirmationCell.getCellHeight(for: groupBooking.bookings[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupBooking.bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupBookingConfirmationCell.identifier) as! GroupBookingConfirmationCell
        cell.setupCell(with: groupBooking.bookings[indexPath.row])
        return cell
    }
    
}

// MARK: - Handle Group Booking
extension GSRGroupConfirmBookingViewModel: UITableViewDelegate {
    fileprivate func handleGroupBookingResponse(_ groupBookingResponse: GSRGroupBookingResponse) {
        ///Update groupBooking with data from groupBookingResponse
        DispatchQueue.main.async {
            var updatedRoomBookings = GSRGroupRoomBookings()
            for room in groupBookingResponse.rooms {
                guard let roomid = Int(room.roomid) else { continue }
                guard let oldRoom = (self.groupBooking.bookings.filter { (roomBooking) -> Bool in
                    roomBooking.roomid == roomid
                }).first else {continue}
                guard let start = room.bookings.first?.start else { continue }
                guard let end = room.bookings.last?.end else { continue }
                #warning("IN THE FUTURE, return an int from the server for room id")
                let updatedRoomBooking = GSRGroupRoomBooking(roomid: roomid, roomName: oldRoom.roomName, location: oldRoom.location, start: start, end: end, bookingSlots: room.bookings)
                updatedRoomBookings.append(updatedRoomBooking)
            }
            self.groupBooking.bookings = updatedRoomBookings
            self.delegate?.reloadData()
        }
    }
}


// MARK: - Networking
extension GSRGroupConfirmBookingViewModel {
    func submitBooking() {
        GSRGroupNetworkManager.instance.submitBooking(booking: groupBooking, completion: { (groupBookingResponse, error)  in
            if let error = error {
                print("error: \(error)")
            } else if let groupBookingResponse = groupBookingResponse {
                self.handleGroupBookingResponse(groupBookingResponse)
            }
        })
    }
}
