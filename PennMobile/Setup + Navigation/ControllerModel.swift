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
    case subletting = "Subletting"
}

class ControllerModel: NSObject {

    static var shared = ControllerModel()

    // Features that can be added to the tab bar
    var dynamicFeatures: [Feature] = [.dining, .studyRoomBooking, .laundry, .news, .contacts, .courseSchedule, .events, .fitness, .polls, .subletting]

    var featureIcons: [Feature: UIImage]! = [.dining: #imageLiteral(resourceName: "Dining"), .studyRoomBooking: #imageLiteral(resourceName: "GSR"), .laundry: #imageLiteral(resourceName: "Laundry"), .news: #imageLiteral(resourceName: "News"), .contacts: #imageLiteral(resourceName: "Contacts"), .courseSchedule: #imageLiteral(resourceName: "Calendar Light"), .events: #imageLiteral(resourceName: "Event"), .fitness: #imageLiteral(resourceName: "Fitness"), .polls: #imageLiteral(resourceName: "Polls"), .courseAlerts: #imageLiteral(resourceName: "PCA"), .about: #imageLiteral(resourceName: "logo-small"), .subletting: #imageLiteral(resourceName: "logo-small")]

}
