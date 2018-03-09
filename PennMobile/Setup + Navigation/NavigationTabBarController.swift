//
//  NavigationTabBarController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation
import UIKit

final class NavigationTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareControllers()
    }
}

// MARK: - Prepare + Setup
extension NavigationTabBarController {
    fileprivate func prepareControllers() {
        let tabBarOrder = ControllerModel.shared.tabBarOrder
        tabBarOrder.forEach { (page) in
            ControllerModel.shared.viewController(for: page).tabBarItem = getTabBarItem(for: page)
        }
        
        self.viewControllers = ControllerModel.shared.viewControllers.map {
            UINavigationController(rootViewController: $0)
        }
    }
    
    func getTabBarItem(for page: Page) -> UITabBarItem {
        let tabBarSystemItem: UITabBarSystemItem
        switch page {
        case .home:
            tabBarSystemItem = .featured
        case .contacts:
            tabBarSystemItem = .more
        default:
            tabBarSystemItem = .favorites
        }
        return UITabBarItem(tabBarSystemItem: tabBarSystemItem, tag: 0)
    }
}
