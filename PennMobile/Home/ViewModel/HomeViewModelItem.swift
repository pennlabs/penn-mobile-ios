//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation

struct HomeItemTypes {
    static let instance: HomeItemTypes = HomeItemTypes()
    private init() {}
    
    let dining: HomeViewModelItem.Type = HomeViewModelDiningItem.self
    let laundry: HomeViewModelItem.Type = HomeViewModelLaundryItem.self
    let studyRoomBooking: HomeViewModelItem.Type = HomeViewModelStudyRoomItem.self
    
    func getItemType(for key: String) -> HomeViewModelItem.Type? {
        let mirror = Mirror(reflecting: self)
        for (_, itemType) in mirror.children {
            guard let itemType = itemType as? HomeViewModelItem.Type else { continue }
            if key == itemType.jsonKey {
                return itemType
            }
        }
        return nil
    }
    
    func registerCells(for tableView: UITableView) {
        let mirror = Mirror(reflecting: self)
        for (_, itemType) in mirror.children {
            guard let itemType = itemType as? HomeViewModelItem.Type else { continue }
            tableView.register(itemType.associatedCell, forCellReuseIdentifier: itemType.associatedCell.identifier)
        }
    }
}

// MARK: - HomeViewModelItem
protocol HomeViewModelItem {
    var title: String { get }
    func equals(item: HomeViewModelItem) -> Bool
    static var jsonKey: String { get }
    static func getItem(for json: JSON?) -> HomeViewModelItem?
    static var associatedCell: HomeCellConformable.Type { get }
}

extension HomeViewModelItem {
    var cellIdentifier: String {
        return Self.associatedCell.identifier
    }
    
    var cellHeight: CGFloat {
        return Self.associatedCell.getCellHeight(for: self)
    }
}

// MARK: - HomeViewModelEventItem
final class HomeViewModelDiningItem: HomeViewModelItem {
    var title: String {
        return "Dining"
    }
    
    static var associatedCell: HomeCellConformable.Type {
        return HomeDiningCell.self
    }
    
    var venues: [DiningVenue]
    
    init(venues: [DiningVenue]) {
        self.venues = venues
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        guard let item = item as? HomeViewModelDiningItem else { return false }
        return venues == item.venues
    }
    
    static var jsonKey: String {
        return "dining"
    }
    
    static func getItem(for json: JSON?) -> HomeViewModelItem? {
        guard let json = json else { return nil }
        return try? HomeViewModelDiningItem(json: json)
    }
}

// MARK: - HomeViewModelStudyRoomItem
final class HomeViewModelStudyRoomItem: HomeViewModelItem {
    var title: String {
        return "Study Room Booking"
    }
    
    static var associatedCell: HomeCellConformable.Type {
        return HomeStudyRoomCell.self
    }
    
    func equals(item: HomeViewModelItem) -> Bool {
        return true
    }
    
    static var jsonKey: String {
        return "studyRoomBooking"
    }
    
    static func getItem(for json: JSON?) -> HomeViewModelItem? {
        return HomeViewModelStudyRoomItem()
    }
}

// MARK: - HomeViewModelLaundryItem
final class HomeViewModelLaundryItem: HomeViewModelItem {
    var title: String {
        return "Laundry"
    }
    
    static var associatedCell: HomeCellConformable.Type {
        return HomeLaundryCell.self
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
    
    static var jsonKey: String {
        return "laundry"
    }
    
    static func getItem(for json: JSON?) -> HomeViewModelItem? {
        guard let json = json else { return nil }
        return try? HomeViewModelLaundryItem(json: json)
    }
}
