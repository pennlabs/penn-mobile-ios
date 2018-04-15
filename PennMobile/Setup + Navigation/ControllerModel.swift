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
    case more = "More"
    case news = "News"
    case contacts = "Penn Contacts"
    case fling = "Spring Fling"
    case about = "About"
    case mentalHealth = "Mental Health"
}

class ControllerModel: NSObject {
    
    static var shared = ControllerModel()
    
    let vcDictionary: [Page: UIViewController] = {
        var dict = [Page: UIViewController]()
        dict[.home] = HomeViewController()
        dict[.dining] = DiningViewController()
        dict[.studyRoomBooking] = GSRController()
        dict[.laundry] = LaundryTableViewController()
        dict[.more] = MoreViewController()
        dict[.news] = NewsViewController()
        dict[.contacts] = ContactsTableViewController()
        dict[.fling] = FlingViewController()
        dict[.about] = AboutViewController()
        dict[.mentalHealth] = MentalHealthViewController()
        return dict
    }()
    
    var viewControllers: [UIViewController] {
        return orderedPages.map { (title) -> UIViewController in
            return vcDictionary[title]!
        }
    }
    
    // pages order in tab bar
    var orderedPages: [Page] {
        get {
            if (ControllerModel.isFlingDate()) {
                return [.fling, .dining, .laundry, .studyRoomBooking, .more]
            }
            return [.dining, .studyRoomBooking, .laundry, .fling, .more]
        }
    }
        
    // pages order in MoreViewController:
    var moreOrder: [Page] {
        get {
            if (ControllerModel.isFlingDate()) {
                return [.news, .contacts, .about, .mentalHealth]
            }
            return [.news, .contacts, .about, .mentalHealth]
        }
    }
    var moreIcons: [UIImage] {
        get {
            if (ControllerModel.isFlingDate()) {
                return [ #imageLiteral(resourceName: "News"), #imageLiteral(resourceName: "Contacts"), #imageLiteral(resourceName: "Penn Labs"), #imageLiteral(resourceName: "Contacts")]
            } else {
                return [ #imageLiteral(resourceName: "News"), #imageLiteral(resourceName: "Contacts"), #imageLiteral(resourceName: "Penn Labs"), #imageLiteral(resourceName: "Contacts")]
            }
        }
    }
    
    var displayNames: [String] {
        return orderedPages.map { $0.rawValue }
    }
    
    func viewController(for controller: Page) -> UIViewController {
        return vcDictionary[controller]!
    }
    
    func viewControllers(for pages: [Page]) -> [UIViewController] {
        return pages.map { viewController(for: $0) }
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
    }
}

extension ControllerModel {
    fileprivate static func isFlingDate() -> Bool {
        let beginDateString = "2018-04-13T05:00:00-04:00"
        let endDateString = "2018-04-15T05:00:00-04:00"
        // standard iso formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let startDate = dateFormatter.date(from: beginDateString)!
        let endDate = dateFormatter.date(from:endDateString)!
        // comparison
        let today = Date()
        return (today > startDate && today < endDate)
    }
    
    static func isReloadNecessary() -> Bool {
        return isFlingDate()
    }
}
