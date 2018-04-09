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
    
    var bookingOptions: [(StudyRoomBookingOption?, StudyRoomBookingOption?, StudyRoomBookingOption?)]?
    
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

/*
// MARK: - JSON Parsing
extension HomeGSRCellItem {
    convenience init(json: JSON) throws {
        guard let ids = json["venues"].arrayObject as? [Int] else {
            throw NetworkingError.jsonError
        }
        var venues: [DiningVenue] = ids.map { try? DiningVenue(id: $0) }.filter { $0 != nil}.map { $0! }
        if venues.isEmpty {
            venues = DiningVenue.getDefaultVenues()
        }
        self.init(venues: venues)
    }
}*/

// MARK: - API Fetching
extension HomeGSRCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        
        GSRNetworkManager.instance.getAvailability(for: 1086, dateStr: "2018-04-9") { (rooms) in
            if let _ = rooms {
                self.filterForTimeConstraints(rooms!)
            }
            completion()
        }
    }
    
    private func filterForTimeConstraints(_ rooms: [GSRRoom]) {
        let wicRooms = rooms.filter { $0.gid == 1889 }
        let wicRoomsWith60 = wicRooms.filter { $0.timeSlots.first60 != nil }
        let wicRoomsWith90 = wicRooms.filter { $0.timeSlots.first90 != nil }
        
        print("WIC Rooms with 30: \(wicRooms.count)")
        print("WIC Rooms with 60: \(wicRoomsWith60.count)")
        print("WIC Rooms with 90: \(wicRoomsWith90.count)")

        let first30TimeSlot = getFirst30(wicRooms)
        let first60TimeSlot = getFirst60(wicRoomsWith60)
        let first90TimeSlot = getFirst90(wicRoomsWith90)
        
    }
    
    private func getFirst30(_ rooms: [GSRRoom]) -> GSRTimeSlot? {
        let first30TimeSlot : GSRTimeSlot? = rooms.min()?.timeSlots.first
        print(first30TimeSlot?.getLocalTimeString())
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
        print(first60TimeSlot?.getLocalTimeString())
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
        print(first90TimeSlot?.getLocalTimeString())
        return first90TimeSlot
    }
}
