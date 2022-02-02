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
    func handleTransition(to feature: Feature)
}

enum Feature: String {
    case home = "Home"
    case dining = "Dining"
    case studyRoomBooking = "Study Room Booking"
    case laundry = "Laundry"
    case more = "More"
    case fitness = "Fitness"
    case map = "Map"
    case news = "News"
    case contacts = "Penn Contacts"
    case events = "Penn Events"
    case about = "About"
    case fling = "Spring Fling"
    case event = "Event"
    case privacy = "Privacy"
    case notifications = "Notifications"
    case courseSchedule = "Course Schedule"
    case pacCode = "PAC Code"
    case courseAlerts = "Penn Course Alert"
}

class ControllerModel: NSObject {

    static var shared = ControllerModel()

    var vcDictionary: [Feature: UIViewController]!

    func prepare() {
        vcDictionary = [Feature: UIViewController]()
        vcDictionary[.home] = HomeViewController()
//        if #available(iOS 14, *) {
//            vcDictionary[.dining] = DiningViewControllerSwiftUI()
//        } else {
            vcDictionary[.dining] = DiningViewController()
//        }
        vcDictionary[.studyRoomBooking] = GSRTabController()
        vcDictionary[.laundry] = LaundryTableViewController()
        vcDictionary[.more] = MoreViewController()
        vcDictionary[.map] = MapViewController()
        vcDictionary[.news] = NewsViewController()
        vcDictionary[.contacts] = ContactsTableViewController()
        vcDictionary[.about] = AboutViewController()
        vcDictionary[.notifications] = NotificationViewController()
        vcDictionary[.privacy] = PrivacyViewController()
        vcDictionary[.courseSchedule] = CourseScheduleViewController()
        vcDictionary[.pacCode] = PacCodeViewController()
        vcDictionary[.courseAlerts] = CourseAlertController()
        vcDictionary[.events] = PennEventsTableViewController()
        //vcDictionary[.fitness] = FitnessViewController()
        //vcDictionary[.fling] = FlingViewController()
    }

    var viewControllers: [UIViewController] {
        return orderedFeatures.map { (title) -> UIViewController in
            return vcDictionary[title]!
        }
    }

    // Features order in tab bar
    var orderedFeatures: [Feature] {
        get {
            return [.home, .dining, .studyRoomBooking, .laundry, .more]
        }
    }

    // Features order in MoreViewController:
    var moreOrder: [Feature] {
        get {
            //keeping this #if DEBUG in case we want to remove course alerts from production
            //courseAlerts should only show up in testflight but we should NEVER show in production, need to manually remove it in the future
            #if DEBUG
            return [.news, .contacts, .courseSchedule, .courseAlerts, .events, .about]
            #else
            return [.news, .contacts, .courseSchedule, .events, .about]
            #endif
        }
    }

    var moreIcons: [UIImage] {
        //keeping this #if DEBUG in case we want to remove course alerts from production
        //courseAlerts should only show up in testflight but we should NEVER show in production, need to manually remove it in the future
        get {
            #if DEBUG
                return [#imageLiteral(resourceName: "News"), #imageLiteral(resourceName: "Contacts"), #imageLiteral(resourceName: "Calendar Light"), #imageLiteral(resourceName: "PCA"), #imageLiteral(resourceName: "Event"), #imageLiteral(resourceName: "logo-small")]
            #else
                return [#imageLiteral(resourceName: "News"), #imageLiteral(resourceName: "Contacts"), #imageLiteral(resourceName: "Calendar Light"), #imageLiteral(resourceName: "Event"), #imageLiteral(resourceName: "logo-small")]
            #endif
        }
    }

    var displayNames: [String] {
        return orderedFeatures.map { $0.rawValue }
    }

    func viewController(for controller: Feature) -> UIViewController {
        return vcDictionary[controller]!
    }

    func viewControllers(for features: [Feature]) -> [UIViewController] {
        return features.map { viewController(for: $0) }
    }

    var firstVC: UIViewController {
        return viewController(for: firstFeature)
    }

    var firstFeature: Feature {
        //return UserDefaults.standard.isOnboarded() ? orderedFeatures[0] : .laundry
        return orderedFeatures[0]
    }

    func visibleVCIndex() -> IndexPath {
        for vc in viewControllers where vc.isVisible {
            return IndexPath(row: viewControllers.firstIndex(of: vc)!, section: 0)
        }
        return IndexPath(row: 0, section: 0)
    }

    func visibleFeature() -> Feature {
        return orderedFeatures[visibleVCIndex().row]
    }

    func visibleVC() -> UIViewController {
        return viewController(for: visibleFeature())
    }

}

// MARK: - Transitions
extension ControllerModel {
    func transition(to feature: Feature, withAnimation: Bool) {
    }
}
