//
//  HomeGSRCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeGSRCellItem: HomeCellItem {

    static var associatedCell: ModularTableViewCell.Type {
        return HomeStudyRoomCell.self
    }

    var title: String {
        return "Study Room Booking"
    }
    
    init() {
    }
    
    var bookingOptions: [[GSRBooking?]]?
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let _ = item as? HomeGSRCellItem else { return false }
        return true
    }
    
    static var jsonKey: String {
        return "studyRoomBooking"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let _ = json else { return nil }
        return HomeGSRCellItem()
    }
}

// MARK: - API Fetching and Parsing
extension HomeGSRCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatter.string(from: Date().roundedDownToHour)
        
//        GSRNetworkManager.instance.getAvailability(for: 1086, dateStr: dateString) { (rooms) in
//            if let rooms = rooms {
//                self.filterForTimeConstraints(rooms)
//            }
//            completion()
//        }
    }
    
    private func filterForTimeConstraints(_ rooms: [GSRRoom]) {
//        let wicRooms = rooms.filter { $0.id == 1889 && $0.roomName.contains("Rm") }
//        let wicBooths = rooms.filter { $0.id == 1889 && $0.roomName.contains("Booth") }
//
//        let gsrLoc = GSRLocation(lid: 1086, gid: 1889, name: "Weigle", kind: "LIBCAL", imageUrl: "URL")
//        var roomBookings = [GSRBooking?]()
//        for i in 1...3 {
//            let roomSlot = getFirstOpenRoom(wicRooms, duration: 30*i)
//            roomBookings.append(getBooking(gsrLoc, roomSlot.0, 1, roomSlot.1))
//        }
//        var boothBookings = [GSRBooking?]()
//        for i in 1...3 {
//            let roomSlot = getFirstOpenRoom(wicBooths, duration: 30*i)
//            boothBookings.append(getBooking(gsrLoc, roomSlot.0, 1, roomSlot.1))
//        }
//        self.bookingOptions = [boothBookings, roomBookings]
    }
    
//    private func getBooking(_ location: GSRLocation, _ slot: GSRTimeSlot?, _ numSlots: Int, _ room: GSRRoom?) -> GSRBooking? {
//        guard let slot = slot else { return nil }
//        var endTime = slot.endTime
//        if numSlots == 2 {
//            guard let lastSlot = slot.next else { return nil }
//            endTime = lastSlot.endTime
//        }
//        if numSlots == 3 {
//            guard let _ = slot.next else { return nil }
//            guard let lastSlot = slot.next!.next else { return nil }
//            endTime = lastSlot.endTime
//        }
//        return GSRBooking(location: location, roomId: slot.roomId, start: slot.startTime, end: endTime, name: room?.name)
//    }
//
//    private func getFirstOpenRoom(_ rooms: [GSRRoom], duration: Int) -> (GSRTimeSlot?, GSRRoom?) {
//        let firstOpenRoom: GSRRoom? = rooms.min { (lhs, rhs) -> Bool in
//            guard let lhsFirst = lhs.timeSlots.firstTimeslot(duration: duration) else {
//                return false
//            }
//            guard let rhsFirst = rhs.timeSlots.firstTimeslot(duration: duration) else {
//                return true
//            }
//            return lhsFirst.startTime <= rhsFirst.startTime
//        }
//        let firstTimeSlot : GSRTimeSlot? = firstOpenRoom?.timeSlots.firstTimeslot(duration: duration)
//        return (firstTimeSlot, firstOpenRoom)
//    }
}
