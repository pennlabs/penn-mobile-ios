//
//  NavigationModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/18/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol TransitionDelegate {
    func handleTransition(to page: Page)
}

enum Page: String {
    case home = "Home"
    case dining = "Dining"
    case studyRoomBooking = "Study Room Booking"
    case laundry = "Laundry"
    case news = "News"
    case contacts = "Penn Contacts"
    case about = "About"
}

class ControllerModel: NSObject {
    
    static var shared = ControllerModel()
    
    let vcDictionary: [Page: UIViewController] = {
        var dict = [Page: UIViewController]()
        dict[.home] = HomeViewController()
        dict[.dining] = DiningViewController()
        dict[.studyRoomBooking] = GSROverhallController()
        dict[.laundry] = LaundryTableViewController()
        dict[.news] = NewsViewController()
        dict[.contacts] = ContactsTableViewController()
        dict[.about] = AboutViewController()
        return dict
    }()
    
    var viewControllers: [UIViewController] {
        return orderedPages.map { (title) -> UIViewController in
            return vcDictionary[title]!
        }
    }
    
    let orderedPages: [Page] = [.dining, .studyRoomBooking, .laundry, .news, .contacts, .about]
    
    var displayNames: [String] {
        return orderedPages.map { $0.rawValue }
    }
    
    func viewController(for controller: Page) -> UIViewController {
        return vcDictionary[controller]!
    }
    
    var firstVC: UIViewController {
        return viewController(for: firstPage)
    }
    
    var firstPage: Page {
        return UserDefaults.standard.isOnboarded() ? orderedPages[0] : .laundry
    }
    
    func visibleVCIndex() -> IndexPath {
        for vc in viewControllers {
            if vc.isVisible {
                return IndexPath(row: viewControllers.index(of: vc)!, section: 0)
            }
        }
        return IndexPath(row: 0, section: 0)
    }
    
    func visiblePage() -> Page {
        return orderedPages[visibleVCIndex().row]
    }
    
    func visibleVC() -> UIViewController {
        return viewController(for: visiblePage())
    }
}

// MARK: - Transitions
extension ControllerModel {
    func transition(to page: Page, withAnimation: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let masterVC = appDelegate.masterTableViewController
        masterVC.transition(to: page)
    }
}
