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
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBar.isTranslucent = false

        ControllerModel.shared.viewControllers.forEach { (vc) in
            if vc is TabBarShowable {
                vc.tabBarItem = (vc as! TabBarShowable).getTabBarItem()
            }
        }
        self.viewControllers = ControllerModel.shared.viewControllers
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func reloadTabs() {
        let controllerModel = ControllerModel.shared
        if (ControllerModel.isReloadNecessary()) {
            controllerModel.viewControllers.forEach { (vc) in
                if vc is TabBarShowable {
                    vc.tabBarItem = (vc as! TabBarShowable).getTabBarItem()
                }
            }
            self.viewControllers = controllerModel.viewControllers
            self.delegate = self
        }
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

/*extension FlingViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Fling_Grey")
        let selectedImage = UIImage(named: "Fling_Blue")
        return UITabBarItem(title: "Fling", image: normalImage, selectedImage: selectedImage)
    }
}*/

extension DiningViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Dining_Grey")
        let selectedImage = UIImage(named: "Dining_Blue")
        return UITabBarItem(title: "Dining", image: normalImage, selectedImage: selectedImage)
    }
}

extension GSRController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "GSR_Grey")
        let selectedImage = UIImage(named: "GSR_Blue")
        return UITabBarItem(title: "GSR", image: normalImage, selectedImage: selectedImage)
    }
}

extension GSRLocationsController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "GSR_Grey")
        let selectedImage = UIImage(named: "GSR_Blue")
        return UITabBarItem(title: "GSR", image: normalImage, selectedImage: selectedImage)
    }
}

extension GSRTabController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "GSR_Grey")
        let selectedImage = UIImage(named: "GSR_Blue")
        return UITabBarItem(title: "GSR", image: normalImage, selectedImage: selectedImage)
    }
}

extension LaundryTableViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Laundry_Grey")
        let selectedImage = UIImage(named: "Laundry_Blue")
        return UITabBarItem(title: "Laundry", image: normalImage, selectedImage: selectedImage)
    }
}

extension FitnessViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Fitness_Grey")
        let selectedImage = UIImage(named: "Fitness_Blue")
        return UITabBarItem(title: "Fitness", image: normalImage, selectedImage: selectedImage)
    }
}

extension MoreViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "More_Grey")
        let selectedImage = UIImage(named: "More_Blue")
        return UITabBarItem(title: "More", image: normalImage, selectedImage: selectedImage)
    }
}

