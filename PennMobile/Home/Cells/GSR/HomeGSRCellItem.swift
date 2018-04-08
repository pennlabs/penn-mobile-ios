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
        
        GSRNetworkManager.instance.getAvailability(for: 1086, dateStr: "2018-04-08") { (rooms) in
            //dump(rooms)
            if let _ = rooms {
                self.filterForTimeConstraints(rooms!)
            }
            completion()
        }
    }
    
    private func filterForTimeConstraints(_ rooms: [GSRRoom]) {
        let wic_rooms = rooms.filter { $0.gid == 1889 }
        dump(getFirst30(wic_rooms))
    }
    
    private func getFirst30(_ rooms: [GSRRoom]) {
        let first30 : GSRRoom? = rooms.min { (room1, room2) -> Bool in
            if room1.timeSlots.first != nil && room2.timeSlots.first != nil {
                return room1.timeSlots.first!.startTime < room2.timeSlots.first!.startTime
            }
            return false
            }
        dump(first30)
    }
    
    private func getFirst60(_ rooms: [GSRRoom]) {
        
    }
    
    private func getFirst90() {
        
    }
}
