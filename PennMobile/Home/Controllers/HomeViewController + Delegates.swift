//
//  HomeViewController + Delegates.swift
//  PennMobile
//
//  Created by Josh Doman on 3/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit
import SafariServices
import SwiftUI
import PennMobileShared

extension HomeViewController: HomeViewModelDelegate {}

// MARK: - URL Selected
extension HomeViewController {
    func handleUrlPressed(urlStr: String, title: String, item: ModularTableViewItem, shouldLog: Bool) {
        self.tabBarController?.title = "Home"
        if let url = URL(string: urlStr) {
            let vc = SFSafariViewController(url: url)
            navigationController?.present(vc, animated: true)
            FirebaseAnalyticsManager.shared.trackEvent(action: .viewWebsite, result: .none, content: urlStr)
        }

        if shouldLog {
            logInteraction(item: item)
        }
    }
}

// MARK: - Laundry Delegate
extension HomeViewController {
    var allowMachineNotifications: Bool {
        return true
    }
}

// MARK: - Dining Delegate
extension HomeViewController {
    func handleVenueSelected(_ venue: DiningVenue) {
        let hostingView = UIHostingController(rootView: DiningVenueDetailView(for: venue)
                                                            .environmentObject(DiningViewModelSwiftUI.instance))
        navigationController?.pushViewController(hostingView, animated: true)
    }

    func handleSettingsTapped(venues: [DiningVenue]) {
        let diningSettings = DiningCellSettingsController()
        diningSettings.setupFromVenues(venues: venues)
        diningSettings.delegate = self
        let nvc = UINavigationController(rootViewController: diningSettings)
        showDetailViewController(nvc, sender: nil)
    }
}

extension HomeViewController: NewsArticleSelectable {
    func handleSelectedArticle(_ article: NewsArticle) {
        let nvc = NativeNewsViewController()
        nvc.article = article
        nvc.title = "News"
        navigationController?.pushViewController(nvc, animated: true)
    }
}

extension HomeViewController: FeatureNavigatable {
    func navigateToFeature(feature: Feature, item: ModularTableViewItem) {
        let vc = ControllerModel.shared.viewController(for: feature)
        vc.title = feature.rawValue
        self.navigationController?.pushViewController(vc, animated: true)

        logInteraction(item: item)
    }
}

// MARK: - Interaction Logging
extension HomeViewController {
    fileprivate func logInteraction(item: ModularTableViewItem) {
        let index = self.tableViewModel.items.firstIndex { (thisItem) -> Bool in
            return thisItem.equals(item: item)
        }
        if let index = index {
            let cellType = type(of: item) as! HomeCellItem.Type
            var id: String?
            if let identifiableItem = item as? LoggingIdentifiable {
                id = identifiableItem.id
            }
            FeedAnalyticsManager.shared.trackInteraction(cellType: cellType.jsonKey, index: index, id: id)
        }
    }
}
