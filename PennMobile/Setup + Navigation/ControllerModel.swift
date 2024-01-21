//
//  NavigationModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/18/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation
import UIKit
import PennMobileShared

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
    case headlineNews = "Headline News"
    case contacts = "Penn Contacts"
    case events = "Penn Events"
    case about = "About"
    case fling = "Spring Fling"
    case event = "Event"
    case privacy = "Privacy"
    case preferences = "Preferences"
    case notifications = "Notifications"
    case courseSchedule = "Course Schedule"
    case pacCode = "PAC Code"
    case courseAlerts = "Penn Course Alert"
    case polls = "Poll History"
}

class ControllerModel: NSObject {

    static var shared = ControllerModel()

    // Features that can be added to the tab bar
    var dynamicFeatures: [Feature] = [.dining, .studyRoomBooking, .laundry, .news, .contacts, .courseSchedule, .events, .fitness, .polls]

    var featureIcons: [Feature: UIImage]! = [.dining: #imageLiteral(resourceName: "Dining"), .studyRoomBooking: #imageLiteral(resourceName: "GSR"), .laundry: #imageLiteral(resourceName: "Laundry"), .news: #imageLiteral(resourceName: "News"), .contacts: #imageLiteral(resourceName: "Contacts"), .courseSchedule: #imageLiteral(resourceName: "Calendar Light"), .events: #imageLiteral(resourceName: "Event"), .fitness: #imageLiteral(resourceName: "Fitness"), .polls: #imageLiteral(resourceName: "Polls"), .courseAlerts: #imageLiteral(resourceName: "PCA"), .about: #imageLiteral(resourceName: "logo-small")]

    var vcDictionary: [Feature: UIViewController]!

    func prepare() {
        vcDictionary = [Feature: UIViewController]()
        vcDictionary[.home] = HomeViewController()
        vcDictionary[.dining] = DiningViewControllerSwiftUI()
        vcDictionary[.studyRoomBooking] = GSRTabController()
        vcDictionary[.laundry] = LaundryTableViewController()
        vcDictionary[.more] = MoreViewController()
        vcDictionary[.map] = MapViewController()
        vcDictionary[.news] = NewsViewController()
        vcDictionary[.contacts] = ContactsTableViewController()
        vcDictionary[.about] = AboutViewController()
        vcDictionary[.notifications] = NotificationsViewControllerSwiftUI()
        vcDictionary[.preferences] = PreferencesViewController()
        vcDictionary[.privacy] = PrivacyViewController()
        vcDictionary[.courseSchedule] = CoursesViewController()
        vcDictionary[.pacCode] = PacCodeViewController()
        vcDictionary[.courseAlerts] = CourseAlertController()
        vcDictionary[.events] = PennEventsTableViewController()
        vcDictionary[.headlineNews] = NativeNewsViewController()
        vcDictionary[.fitness] = FitnessViewController()
        vcDictionary[.polls] = PollsViewController()
        // vcDictionary[.fling] = FlingViewController()
    }

    var viewControllers: [UIViewController] {
        return tabFeatures.map { (title) -> UIViewController in
            return vcDictionary[title]!
        }
    }

    // Features in tab bar
    var tabFeatures: [Feature] {
        get {
            return UserDefaults.standard.getTabPreferences()
        }
    }

    // Features in MoreViewController:
    var moreFeatures: [Feature] {
        get {
            let tabPreferences = UserDefaults.standard.getTabPreferences()
            return dynamicFeatures.filter { !tabPreferences.contains($0) } + [.about]
        }
    }

    var moreIcons: [UIImage] {
        get {
            return moreFeatures.map { featureIcons[$0] ?? #imageLiteral(resourceName: "logo-small") }
        }
    }

    var displayNames: [String] {
        return tabFeatures.map { $0.rawValue }
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
        // return UserDefaults.standard.isOnboarded() ? tabFeatures[0] : .laundry
        return tabFeatures[0]
    }

    func visibleVCIndex() -> IndexPath {
        for vc in viewControllers where vc.isVisible {
            return IndexPath(row: viewControllers.firstIndex(of: vc)!, section: 0)
        }
        return IndexPath(row: 0, section: 0)
    }

    func visibleFeature() -> Feature {
        return tabFeatures[visibleVCIndex().row]
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
