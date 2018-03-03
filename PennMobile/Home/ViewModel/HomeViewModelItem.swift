//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

// MARK: - HomeViewModelType
enum HomeViewModelItemType: String {
    case event
    case dining
    case studyRoomBooking
    case laundry
}

// MARK: - HomeViewModelItem
protocol HomeViewModelItem {
    var type: HomeViewModelItemType { get }
    var title: String { get }
    func equals(item: HomeViewModelItem) -> Bool
}

// MARK: - HomeViewModelEventItem
final class HomeViewModelEventItem: HomeViewModelItem {
    var type: HomeViewModelItemType {
        return .event
    }
    
    var title: String {
        return "Event"
    }
    
    var imageUrl: String
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        guard let item = item as? HomeViewModelEventItem else { return false }
        return imageUrl == item.imageUrl
    }
}

// MARK: - HomeViewModelEventItem
final class HomeViewModelDiningItem: HomeViewModelItem {
    var type: HomeViewModelItemType {
        return .dining
    }
    
    var title: String {
        return "Dining"
    }
    
    var venues: [DiningVenue]
    
    init(venues: [DiningVenue]) {
        self.venues = venues
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        guard let item = item as? HomeViewModelDiningItem else { return false }
        return venues == item.venues
    }
}

// MARK: - HomeViewModelStudyRoomItem
final class HomeViewModelStudyRoomItem: HomeViewModelItem {
    var type: HomeViewModelItemType {
        return .studyRoomBooking
    }
    
    var title: String {
        return "Study Room Booking"
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        return true
    }
}

// MARK: - HomeViewModelLaundryItem
final class HomeViewModelLaundryItem: HomeViewModelItem {
    var type: HomeViewModelItemType {
        return .laundry
    }
    
    var title: String {
        return "Laundry"
    }
    
    var room: LaundryRoom
    var timer: Timer?       // For decrementing machines
    
    init(room: LaundryRoom) {
        self.room = room
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        guard let item = item as? HomeViewModelLaundryItem else { return false }
        return room == item.room
    }
}

