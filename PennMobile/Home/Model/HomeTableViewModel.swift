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
        let item = items[indexPath.row]
        let cellType = type(of: item) as! HomeCellItem.Type
        var id: String? = nil
        if let identifiableItem = item as? LoggingIdentifiable {
            id = identifiableItem.id
        }
        FeedAnalyticsManager.shared.track(cellType: cellType.jsonKey, index: indexPath.row, id: id, batchSize: items.count)
    }
}
