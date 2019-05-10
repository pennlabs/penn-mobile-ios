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

class HomeTableViewModel: ModularTableViewModel {}

// MARK: - Preload Webview
extension HomeTableViewModel {
    func venueToPreload() -> DiningVenue? {
        let diningItems = self.items.filter { $0.cellIdentifier == HomeDiningCell.identifier }
        guard let diningItem = diningItems.first as? HomeDiningCellItem else { return nil }
        return diningItem.venues.first
    }
    
    func getItems(for itemTypes: [HomeCellItem.Type]) -> [HomeCellItem] {
        guard let allItems = self.items as? [HomeCellItem] else { return [] }
        let items = allItems.filter { (item) -> Bool in
            return itemTypes.contains(where: { (itemType) -> Bool in
                return itemType.jsonKey == type(of: item).jsonKey
            })
        }
        return items
    }
}

// MARK: - UITableViewDelegate + Tracking
extension HomeTableViewModel {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! HomeCellConformable
        cell.trackingTime = Date().timeIntervalSince1970
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! HomeCellConformable
        guard let startTime = cell.trackingTime else { return }
        let endTime = Date().timeIntervalSince1970
        let duration = endTime - startTime
        print(duration)
    }
}
