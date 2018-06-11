//
//  HomeGSRCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

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
    
    func equals(item: HomeCellItem) -> Bool {
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
        
        GSRNetworkManager.instance.getAvailability(for: 1086, dateStr: dateString) { (rooms) in
            if let _ = rooms {
                self.filterForTimeConstraints(rooms!)
            }
            completion()
        }
    }
    
    private func filterForTimeConstraints(_ rooms: [GSRRoom]) {
        let wicRooms = rooms.filter { $0.gid == 1889 && $0.name.contains("Rm") }
        let wicBooths = rooms.filter { $0.gid == 1889 && $0.name.contains("Booth") }
        
        let wicRoomsWith60 = wicRooms.filter { $0.timeSlots.first60 != nil }
        let wicRoomsWith90 = wicRoomsWith60.filter { $0.timeSlots.first90 != nil }
        let wicBoothsWith60 = wicBooths.filter { $0.timeSlots.first60 != nil }
        let wicBoothsWith90 = wicBoothsWith60.filter { $0.timeSlots.first90 != nil }

        let firstRoomSlot30 = getFirst30(wicRooms)
        let firstRoomSlot60 = getFirst60(wicRoomsWith60)
        let firstRoomSlot90 = getFirst90(wicRoomsWith90)
        let firstBoothSlot30 = getFirst30(wicBooths)
        let firstBoothSlot60 = getFirst60(wicBoothsWith60)
        let firstBoothSlot90 = getFirst90(wicBoothsWith90)
        
        let gsrLoc = GSRLocation(lid: 1086, gid: 1889, name: "Weigle", service: "libcal")
        self.bookingOptions = [[getBooking(gsrLoc, firstBoothSlot30, 1),
                                getBooking(gsrLoc, firstBoothSlot60, 2),
                                getBooking(gsrLoc, firstBoothSlot90, 3)],
                               [getBooking(gsrLoc, firstRoomSlot30, 1),
                                getBooking(gsrLoc, firstRoomSlot60, 2),
                                getBooking(gsrLoc, firstRoomSlot90, 3)]]
    }
    
    private func getBooking(_ location: GSRLocation, _ slot: GSRTimeSlot?, _ numSlots: Int) -> GSRBooking? {
        guard let slot = slot else { return nil }
        var endTime = slot.endTime
        if numSlots == 2 {
            guard let lastSlot = slot.next else { return nil }
            endTime = lastSlot.endTime
        }
        if numSlots == 3 {
            guard let _ = slot.next else { return nil }
            guard let lastSlot = slot.next!.next else { return nil }
            endTime = lastSlot.endTime
        }
        return GSRBooking(location: location, roomId: slot.roomId, start: slot.startTime, end: endTime)
    }
    
    private func getFirst30(_ rooms: [GSRRoom]) -> GSRTimeSlot? {
        let first30TimeSlot : GSRTimeSlot? = rooms.min()?.timeSlots.first
        return first30TimeSlot
    }
    
    private func getFirst60(_ rooms: [GSRRoom]) -> GSRTimeSlot? {
        let first60Room : GSRRoom? = rooms.min { (lhs, rhs) -> Bool in
            guard let lhsFirst60 = lhs.timeSlots.first60, let rhsFirst60 = rhs.timeSlots.first60 else {
                return false
            }
            return lhsFirst60.startTime <= rhsFirst60.startTime
        }
        let first60TimeSlot : GSRTimeSlot? = first60Room?.timeSlots.first60
        return first60TimeSlot
    }
    
    private func getFirst90(_ rooms: [GSRRoom]) -> GSRTimeSlot? {
        let first90Room : GSRRoom? = rooms.min { (lhs, rhs) -> Bool in
            guard let lhsFirst90 = lhs.timeSlots.first90, let rhsFirst90 = rhs.timeSlots.first90 else {
                return false
            }
            return lhsFirst90.startTime <= rhsFirst90.startTime
        }
        let first90TimeSlot : GSRTimeSlot? = first90Room?.timeSlots.first90
        return first90TimeSlot
    }
}
