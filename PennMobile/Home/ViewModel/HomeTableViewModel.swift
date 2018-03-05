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
}
