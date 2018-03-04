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
        items = HomeViewModel.defaultOrdering.map { try! HomeViewModel.generateItem(for: $0) }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let identifier = item.cellIdentifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! HomeCellConformable
        cell.item = item
        cell.delegate = self.delegate
        return cell as! UITableViewCell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        return item.cellHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        return item.cellHeight
    }
}

// MARK: - Preload Webview
extension HomeViewModel {
    func venueToPreload() -> DiningVenue? {
        let diningItems = self.items.filter { $0.type == .dining }
        guard let diningItem = diningItems.first as? HomeViewModelDiningItem else { return nil }
        return diningItem.venues.first
    }
}
