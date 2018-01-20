//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate: TransitionDelegate {}

class HomeViewModel: NSObject {
    var items = [HomeViewModelItem]()
    
    static var defaultOrdering: [HomeViewModelItemType] = [.event, .dining, .laundry, .studyRoomBooking]
    
    var delegate: HomeViewModelDelegate!
    
    convenience override init() {
        let user = User()
        let event = Event(imageUrl: "eventUrl.com")
        self.init(user: user, event: event)
    }
    
    init(user: User, event: Event? = nil, ordering: [HomeViewModelItemType]? = nil) {
        items = HomeViewModel.generateItems(user: user, event: event, with: ordering ?? HomeViewModel.defaultOrdering)
        super.init()
    }
    
    static func generateItems(user: User, event: Event?, with orderedTypes: [HomeViewModelItemType]) -> [HomeViewModelItem] {
        var items = [HomeViewModelItem]()
        for type in orderedTypes {
            let item: HomeViewModelItem
            switch type {
            case .event:
                guard let event = event else { continue }
                item = HomeViewModelEventItem(imageUrl: event.imageUrl)
            case .dining:
                let venues = !user.preferredVenues.isEmpty ? user.preferredVenues : DiningVenue.getDefaultVenues()
                item = HomeViewModelDiningItem(venues: venues)
            case .laundry:
                let rooms = !user.preferredLaundryRooms.isEmpty ? user.preferredLaundryRooms : LaundryRoom.getDefaultRooms()
                item = HomeViewModelLaundryItem(rooms: rooms)
            case .studyRoomBooking:
                item = HomeViewModelStudyRoomItem()
            }
            items.append(item)
        }
        return items
    }
}

// MARK: - UITableViewDataSource
extension HomeViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        let item = items[indexPath.row]
        switch item.type {
        case .event:
            identifier = HomeEventCell.identifier
        case .dining:
            identifier = HomeDiningCell.identifier
        case .laundry:
            identifier = HomeLaundryCell.identifier
        case .studyRoomBooking:
            identifier = HomeStudyRoomCell.identifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! GeneralHomeCell
        cell.item = item
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        switch item.type {
        case .event:
            return HomeEventCell.cellHeight
        case .dining:
            return HomeDiningCell.cellHeight
        case .laundry:
            return HomeLaundryCell.cellHeight
        case .studyRoomBooking:
            return HomeStudyRoomCell.cellHeight
        }
    }
}

// MARK: - Update Data
extension HomeViewModel {
    func update() {
        for item in items {
            switch item.type {
            case .laundry:
                guard let item = item as? HomeViewModelLaundryItem else { break }
                item.rooms = LaundryRoom.getDefaultRooms()
            default:
                break
            }
        }
    }
}

// MARK: - GeneralHomeCellDelegate
extension HomeViewModel: GeneralHomeCellDelegate {
    func handleTransition(to page: Page) {
        delegate.handleTransition(to: page)
    }
}
