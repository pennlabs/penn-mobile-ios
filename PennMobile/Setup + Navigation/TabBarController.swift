//
//  NavigationTabBarController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation
import UIKit
import ESTabBarController_swift

final class TabBarController: ESTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let v1 = HomeViewController()
//        let v2 = ExampleViewController()
//        let v3 = ExampleViewController()
//        let v4 = ExampleViewController()
//        let v5 = ExampleViewController()
//
//        v1.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Home", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
//        v2.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Find", image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
//        v3.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: nil, image: UIImage(named: "photo_verybig"), selectedImage: UIImage(named: "photo_verybig"))
//        v4.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Favor", image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor_1"))
//        v5.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Me", image: UIImage(named: "me"), selectedImage: UIImage(named: "me_1"))
        ControllerModel.shared.viewControllers.forEach { (vc) in
            if vc is TabBarShowable {
                vc.tabBarItem = (vc as! TabBarShowable).getTabBarItem()
            }
        }
        self.viewControllers = ControllerModel.shared.viewControllers
        self.delegate = self
    }
}

// MARK: - Transition Animation
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let tabBarController = tabBarController as? ESTabBarController, let selectedViewController = tabBarController.selectedViewController else { return false }
        
        if tabBarController.selectedViewController == nil || tabBarController.selectedViewController == viewController {
            return false
        }
        
        let fromView = selectedViewController.view
        let toView = viewController.view
        
        UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        
        return true
    }
}

protocol TabBarShowable {
    func getTabBarItem() -> UITabBarItem
}

extension HomeViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Home_Gray_New")
        let selectedImage = UIImage(named: "Home_Blue_New")
        return ESTabBarItem(title: "Home", image: normalImage, selectedImage: selectedImage)
    }
}

extension DiningViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Dining_Gray_New")
        let selectedImage = UIImage(named: "Dining_Blue_New")
        return ESTabBarItem(title: "Dining", image: normalImage, selectedImage: selectedImage)
    }
}

extension GSRController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "GSR_Gray_New")
        let selectedImage = UIImage(named: "GSR_Blue_New")
        return ESTabBarItem(title: "GSR", image: normalImage, selectedImage: selectedImage)
    }
}

extension LaundryTableViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Laundry_Gray_New")
        let selectedImage = UIImage(named: "Laundry_Blue_New")
        return ESTabBarItem(title: "Laundry", image: normalImage, selectedImage: selectedImage)
    }
}

extension MoreViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "More_Gray_New")
        let selectedImage = UIImage(named: "More_Blue_New")
        return ESTabBarItem(title: "More", image: normalImage, selectedImage: selectedImage)
    }
}

extension ContactsTableViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Home_Gray_New")
        let selectedImage = UIImage(named: "Home_Blue_New")
        return ESTabBarItem(title: "Home", image: normalImage, selectedImage: selectedImage)
    }
}

extension NewsViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Home_Gray_New")
        let selectedImage = UIImage(named: "Home_Blue_New")
        return ESTabBarItem(title: "Home", image: normalImage, selectedImage: selectedImage)
    }
}

extension AboutViewController: TabBarShowable {
    func getTabBarItem() -> UITabBarItem {
        let normalImage = UIImage(named: "Home_Gray_New")
        let selectedImage = UIImage(named: "Home_Blue_New")
        return ESTabBarItem(title: "Home", image: normalImage, selectedImage: selectedImage)
    }
}

