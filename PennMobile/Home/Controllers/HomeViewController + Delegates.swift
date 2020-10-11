//
//  HomeViewController + Delegates.swift
//  PennMobile
//
//  Created by Josh Doman on 3/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit
import SafariServices

extension HomeViewController: HomeViewModelDelegate {}

// MARK: - Reservation Delegate
extension HomeViewController: GSRDeletable {
    func deleteReservation(_ bookingID: String) {
        deleteReservation(bookingID) { (successful) in
            if successful {
                guard let reservationItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.reservations]).first as? HomeReservationsCellItem else { return }
                reservationItem.reservations = reservationItem.reservations.filter { $0.bookingID != bookingID }
                if reservationItem.reservations.isEmpty {
                    self.removeItem(reservationItem)
                } else {
                    self.reloadItem(reservationItem)
                }
            }
        }
    }
    
    func deleteReservation(_ reservation: GSRReservation) {
        deleteReservation(reservation.bookingID)
    }
}




// MARK: - GSR Quick Book Delegate
extension HomeViewController: GSRBookable {
    func handleBookingSelected(_ booking: GSRBooking) {
        confirmBookingWanted(booking)
    }
    
    private func confirmBookingWanted(_ booking: GSRBooking) {
        let message = "Booking \(booking.getRoomName()) from \(booking.getLocalTimeString())"
        let alert = UIAlertController(title: "Confirm Booking",
                                      message: message,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:{ (UIAlertAction) in
            self.handleBookingRequested(booking)
        }))
        present(alert, animated: true)
    }
    
    private func handleBookingRequested(_ booking: GSRBooking) {
        if GSRUser.hasSavedUser() {
            booking.user = GSRUser.getUser()
            submitBooking(for: booking) { (completion) in
                self.fetchCellData(for: [HomeItemTypes.instance.studyRoomBooking])
            }
        } else {
            let glc = GSRLoginController()
            glc.booking = booking
            let nvc = UINavigationController(rootViewController: glc)
            present(nvc, animated: true, completion: nil)
        }
    }
}

// MARK: - URL Selected
extension HomeViewController {
    func handleUrlPressed(urlStr: String, title: String, item: ModularTableViewItem, shouldLog: Bool) {
        self.tabBarController?.title = "Home"
        if let url = URL(string: urlStr) {
            let vc = SFSafariViewController(url: url)
            navigationController?.present(vc, animated: true)
            FirebaseAnalyticsManager.shared.trackEvent(action: .viewWebsite, result: .none, content: urlStr)
        }
        
        if shouldLog {
            logInteraction(item: item)
        }
    }
}

// MARK: - Laundry Delegate
extension HomeViewController {
    var allowMachineNotifications: Bool {
        return true
    }
}

// MARK: - Dining Delegate
extension HomeViewController {
    func handleVenueSelected(_ venue: DiningVenue) {        
        if let url = venue.facilityURL {
            let vc = UIViewController()
            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            webView.load(URLRequest(url: url))
            vc.view.addSubview(webView)
            vc.title = venue.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func handleSettingsTapped(venues: [DiningVenue]) {
        let diningSettings = DiningCellSettingsController()
        diningSettings.setupFromVenues(venues: venues)
        diningSettings.delegate = self
        let nvc = UINavigationController(rootViewController: diningSettings)
        showDetailViewController(nvc, sender: nil)
    }
}

// MARK: - Course Delegate
extension HomeViewController {
    func handleBuildingSelected(searchTerm: String) {
        //        let bmwc = BuildingMapWebviewController(searchTerm: searchTerm)
        let mapVC = MapViewController()
        mapVC.searchTerm = searchTerm
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    // MARK: Course Refresh
    func handleCourseRefresh() {
        let message = "Has there been a change to your schedule? Would you like Penn Mobile to update your courses?"
        let alert = UIAlertController(title: "Update Courses",
                                      message: message,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ (UIAlertAction) in
            //self.showCourseWebviewController()
            self.showActivity()
            PennInTouchNetworkManager.instance.getCourses(currentTermOnly: true, callback: self.handleNetworkCourseRefreshCompletion(_:))
        }))
        present(alert, animated: true)
    }
    
    // MARK: Login to enable courses
    func handleLoggingIn() {
        let cwc = CoursesWebviewController()
        cwc.currentTermOnly = false
        self.tableViewModel = nil
        cwc.completion = { courses in
            if courses != nil {
                UserDefaults.standard.setCoursePermission(true)
            }
        }
        let nvc = UINavigationController(rootViewController: cwc)
        self.present(nvc, animated: true, completion: nil)
    }
}

// MARK: - Course Refreshing
extension HomeViewController: ShowsAlert {
    fileprivate func showCourseWebviewController() {
        let cwc = CoursesWebviewController()
        cwc.completion = self.handleCourseRefresh(_:)
        let nvc = UINavigationController(rootViewController: cwc)
        self.present(nvc, animated: true, completion: nil)
    }
    
    fileprivate func handleNetworkCourseRefreshCompletion(_ result: Result<Set<Course>, NetworkingError>) {
        DispatchQueue.main.async {
            self.hideActivity()
            if let courses = try? result.get() {
                if let accountID = UserDefaults.standard.getAccountID() {
                    UserDBManager.shared.saveCourses(courses, accountID: accountID, { (success) in
                        self.handleCourseRefresh(courses)
                    })
                } else {
                    self.handleCourseRefresh(courses)
                }
                if let currentCourses = UserDefaults.standard.getCourses() {
                    let term = Course.currentTerm
                    let currentCoursesMinusTerm = currentCourses.filter { $0.term != term }
                    let newCourses = currentCoursesMinusTerm.union(courses)
                    UserDefaults.standard.saveCourses(newCourses)
                }
            } else {
                self.showCourseWebviewController()
            }
        }
    }
    
    private func handleCourseRefresh(_ courses: Set<Course>?) {
        DispatchQueue.main.async {
            if let courses = courses, let courseItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.courses]).first as? HomeCoursesCellItem {
                let taughtToday = courses.taughtToday
                let taughtTomorrow = courses.taughtTomorrow
                if taughtToday.isEmpty && taughtTomorrow.isEmpty {
                    self.removeItem(courseItem)
                } else {
                    courseItem.courses = courseItem.weekday == "Today" ? Array(taughtToday) : Array(taughtTomorrow)
                    self.reloadItem(courseItem)
                }
                self.showAlert(withMsg: "Your courses have been updated.", title: "Success!", completion: nil)
            } else {
                self.showAlert(withMsg: "Unable to access your courses. Please try again later.", title: "Uh oh!", completion: nil)
            }
        }
    }
}

extension HomeViewController: GSRLocationSelectable {
    func handleSelectedLocation(_ location: GSRLocation) {
        let gc = GSRController()
        gc.startingLocation = location
        gc.title = "Study Room Booking"
        navigationController?.pushViewController(gc, animated: true)
        FirebaseAnalyticsManager.shared.trackEvent(action: "Tap Home GSR Location", result: "Tap Home GSR Location", content: "View \(location.name)")
    }
}

extension HomeViewController: FeatureNavigatable {
    func navigateToFeature(feature: Feature, item: ModularTableViewItem) {
        let vc = ControllerModel.shared.viewController(for: feature)
        vc.title = feature.rawValue
        self.navigationController?.pushViewController(vc, animated: true)
        
        logInteraction(item: item)
    }
}

// MARK: - Interaction Logging
extension HomeViewController {
    fileprivate func logInteraction(item: ModularTableViewItem) {
        let index = self.tableViewModel.items.firstIndex { (thisItem) -> Bool in
            return thisItem.equals(item: item)
        }
        if let index = index {
            let cellType = type(of: item) as! HomeCellItem.Type
            var id: String? = nil
            if let identifiableItem = item as? LoggingIdentifiable {
                id = identifiableItem.id
            }
            FeedAnalyticsManager.shared.trackInteraction(cellType: cellType.jsonKey, index: index, id: id)
        }
    }
}

//MARK: - Invite delegate
extension HomeViewController: GSRInviteSelectable {
    func handleInviteSelected(_ invite: GSRGroupInvite, _ accept: Bool) {
        GSRGroupNetworkManager.instance.respondToInvite(invite: invite, accept: accept) { (success) in
            if success {
                guard let inviteItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.invites]).first as? HomeGroupInvitesCellItem else { return }
                inviteItem.invites = inviteItem.invites.filter { $0.id != invite.id }
                DispatchQueue.main.async {
                    if inviteItem.invites.isEmpty {
                        self.removeItem(inviteItem)
                    } else {
                        self.reloadItem(inviteItem)
                    }
                }
            } else {
                let message = "An error occured when responding to this invite. Please try again later."
                let alert = UIAlertController(title: invite.group, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
