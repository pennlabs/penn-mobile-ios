//
//  HomeCellProtocols.swift
//  PennMobile
//
//  Created by Josh Doman on 3/25/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol URLSelectable {
    func handleUrlPressed(urlStr: String, title: String, item: ModularTableViewItem, shouldLog: Bool)
}

protocol FeatureNavigatable {
    func navigateToFeature(feature: Feature, item: ModularTableViewItem)
}

protocol ViewControllerNavigatable {
    func navigateToViewController(vc: UIViewController)
}


