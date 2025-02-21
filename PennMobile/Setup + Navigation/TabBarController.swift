//
//  NavigationTabBarController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation
import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBar.standardAppearance = appearance

        // Required to prevent tab bar's appearance from switching between light and dark mode
        tabBar.scrollEdgeAppearance = appearance
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTabs()
    }

    func loadTabs() {
        ControllerModel.shared.viewControllers.forEach { (vc) in
            if vc is TabBarShowable {
                vc.tabBarItem = (vc as! TabBarShowable).getTabBarItem()
            }
        }
        self.viewControllers = ControllerModel.shared.viewControllers
        self.delegate = self
    }
}

// MARK: - Delegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}

protocol TabBarShowable {
    func getTabBarItem() -> UITabBarItem
}

extension HomeViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Home_Grey")
        let selectedImage = UIImage(named: "Home_Blue")
        return UITabBarItem(title: "Home", image: normalImage, selectedImage: selectedImage)
    }
}

extension DiningViewControllerSwiftUI: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Dining_Grey")
        let selectedImage = UIImage(named: "Dining_Blue")
        return UITabBarItem(title: "Dining", image: normalImage, selectedImage: selectedImage)
    }
}

extension LaundryTableViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Laundry_Grey")
        let selectedImage = UIImage(named: "Laundry_Blue")
        return UITabBarItem(title: "Laundry", image: normalImage, selectedImage: selectedImage)
    }
}

extension CoursesViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Calendar_Grey")
        let selectedImage = UIImage(named: "Calendar_Blue")
        return UITabBarItem(title: "Schedule", image: normalImage, selectedImage: selectedImage)
    }
}

extension NewsViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "News_Grey")
        let selectedImage = UIImage(named: "News_Blue")
        return UITabBarItem(title: "News", image: normalImage, selectedImage: selectedImage)
    }
}

extension MoreViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "More_Grey")
        let selectedImage = UIImage(named: "More_Blue")
        return UITabBarItem(title: "More", image: normalImage, selectedImage: selectedImage)
    }
}
