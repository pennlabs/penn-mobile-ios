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
    
    var page: Page? {
        switch self {
        case .dining: return .dining
        case .studyRoomBooking: return .studyRoomBooking
        case .laundry: return .laundry
        default: return nil
        }
    }
}

// MARK: - HomeViewModelItem
protocol HomeViewModelItem {
    var type: HomeViewModelItemType { get }
    var title: String { get }
}

// MARK: - HomeViewModelEventItem
class HomeViewModelEventItem: HomeViewModelItem {
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
class HomeViewModelDiningItem: HomeViewModelItem {
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
class HomeViewModelStudyRoomItem: HomeViewModelItem {
    var type: HomeViewModelItemType {
        return .studyRoomBooking
    }
    
    var title: String {
        return "Study Room Booking"
    }
}

// MARK: - HomeViewModelLaundryItem
class HomeViewModelLaundryItem: HomeViewModelItem {
    var type: HomeViewModelItemType {
        return .laundry
    }
    
    var title: String {
        return "Laundry"
    }
    
    var rooms: [LaundryRoom]
    
    init(rooms: [LaundryRoom]) {
        self.rooms = rooms
    }
}

