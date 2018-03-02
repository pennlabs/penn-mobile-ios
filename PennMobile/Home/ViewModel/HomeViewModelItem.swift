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
}

// MARK: - HomeViewModelStudyRoomItem
final class HomeViewModelStudyRoomItem: HomeViewModelItem {
    var type: HomeViewModelItemType {
        return .studyRoomBooking
    }
    
    var title: String {
        return "Study Room Booking"
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
    
    init(room: LaundryRoom) {
        self.room = room
    }
}

