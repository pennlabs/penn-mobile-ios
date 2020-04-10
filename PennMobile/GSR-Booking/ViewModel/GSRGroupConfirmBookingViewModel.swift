//
//  GSRGroupConfirmBookingViewModel.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 3/13/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SCLAlertView

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
                guard let oldRoom = (self.groupBooking.bookings.filter { (roomBooking) -> Bool in
                    roomBooking.roomid == room.roomid
                }).first else {continue}
                guard let start = room.bookings.first?.start else { continue }
                guard let end = room.bookings.last?.end else { continue }
                let updatedRoomBooking = GSRGroupRoomBooking(roomid: room.roomid, roomName: oldRoom.roomName, location: oldRoom.location, start: start, end: end, bookingSlots: room.bookings)
                updatedRoomBookings.append(updatedRoomBooking)
            }
            self.groupBooking.bookings = updatedRoomBookings
            self.delegate?.reloadData()
        }
    }
}


// MARK: - Networking
extension GSRGroupConfirmBookingViewModel {
    func submitBooking(vc: GSRGroupConfirmBookingController)  {
        vc.showActivity()
        GSRGroupNetworkManager.instance.submitBooking(booking: groupBooking, completion: { (groupBookingResponse, error)  in
            
            DispatchQueue.main.async {
                vc.hideActivity()
                let alertView = SCLAlertView()
                
                if let error = error {
                    print("error: \(error)")
                    alertView.showError("Uh oh!", subTitle: "\(error)")

                } else if let groupBookingResponse = groupBookingResponse {
                    if let error = groupBookingResponse.error {
                        print("error: \(error)")
                        alertView.showError("Uh oh!", subTitle: "\(error)")
                    }
                    self.handleGroupBookingResponse(groupBookingResponse)
                    if (groupBookingResponse.completeSuccess) {
                        alertView.showSuccess("Success!", subTitle: "You group \(self.groupBooking.group.name) booked some space in \(self.groupBooking.bookings[0].location.name). You should receive a confirmation email in the next few minutes.")
                    }
                    
                    
                    
                    guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else { return }
                    homeVC.clearCache()
                    //vc.dismiss(animated: true, completion: nil)
                    
                }
                
            }
            
            
            
            
        })
        
        
        
        
    }
    
//    func submitBooking(for booking: groupBooking, _ completion: @escaping (_ success: Bool) -> Void) {
//        self.showActivity()
//        GSRNetworkManager.instance.makeBooking(for: booking) { (success, errorMessage) in
//            DispatchQueue.main.async {
//                self.hideActivity()
//                let alertView = SCLAlertView()
//                var result: FirebaseAnalyticsManager.EventResult = .failed
//                if success {
//                    alertView.showSuccess("Success!", subTitle: "You booked a space in \(booking.location.name). You should receive a confirmation email in the next few minutes.")
//                    result = .success
//                    guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else { return }
//                    homeVC.clearCache()
//                } else if let msg = errorMessage {
//                    alertView.showError("Uh oh!", subTitle: msg)
//                }
//                FirebaseAnalyticsManager.shared.trackEvent(action: .attemptBooking, result: result, content: booking.location.name)
//                completion(success)
//            }
//        }
//    }
}
