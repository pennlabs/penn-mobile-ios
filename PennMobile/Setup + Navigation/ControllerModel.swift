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

}

// MARK: - Transitions
extension ControllerModel {
    func transition(to feature: Feature, withAnimation: Bool) {
    }
}
