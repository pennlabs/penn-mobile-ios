//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate: HomeCellDelegate {}

class HomeViewModel: NSObject {
    var items = [HomeViewModelItem]()
    
    static var defaultOrdering: [HomeViewModelItemType] = [.event, .dining, .laundry, .studyRoomBooking]
    
    var delegate: HomeViewModelDelegate!
    
    override init() {
        items = HomeViewModel.defaultOrdering.map { HomeViewModel.generateItem(for: $0) }
    }
    
    init(json: JSON) throws {
        guard let cellsJSON = json["cells"].array else {
            throw NetworkingError.jsonError
        }
        let types = cellsJSON.map { HomeViewModelItemType(rawValue: $0["type"].stringValue) }
            .filter { $0 != nil }
            .map { $0! }
        items = types.map { HomeViewModel.generateItem(for: $0) }
    }
    
    static func generateItem(for type: HomeViewModelItemType, info: JSON? = nil) -> HomeViewModelItem {
        switch type {
        case .event:
            let imageUrl = info?["imageUrl"].string ?? ""
            return HomeViewModelEventItem(imageUrl: imageUrl)
        case .dining:
            let venues = DiningVenue.getDefaultVenues()
            return HomeViewModelDiningItem(venues: venues)
        case .laundry:
            let room = LaundryRoom.getDefaultRooms().first!
            return HomeViewModelLaundryItem(room: room)
        case .studyRoomBooking:
            return HomeViewModelStudyRoomItem()
        }
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
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! HomeCellConformable
        cell.item = item
        cell.delegate = self
        return cell as! UITableViewCell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeightforRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeightforRow(at: indexPath)
    }
    
    private func getHeightforRow(at indexPath: IndexPath) -> CGFloat {
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
    func update(_ completion: () -> Void) {
//        for item in items {
//            switch item.type {
//            case .laundry:
//                guard let item = item as? HomeViewModelLaundryItem else { break }
//                item.rooms = LaundryRoom.getDefaultRooms()
//            default:
//                break
//            }
//        }
        completion()
    }
}

// MARK: - GeneralHomeCellDelegate
extension HomeViewModel: HomeCellDelegate {
    var allowMachineNotifications: Bool {
        return delegate.allowMachineNotifications
    }
    
    func handleMachineCellTapped(for machine: LaundryMachine, _ updateCellIfNeeded: @escaping () -> Void) {
        delegate.handleMachineCellTapped(for: machine, updateCellIfNeeded)
    }
    
}
