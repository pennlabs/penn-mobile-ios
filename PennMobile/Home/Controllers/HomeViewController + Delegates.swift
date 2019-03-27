//
//  HomeViewController + Delegates.swift
//  PennMobile
//
//  Created by Josh Doman on 3/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

extension HomeViewController: HomeViewModelDelegate {}

// MARK: - Reservation Delegate
extension HomeViewController: GSRDeletable {
    func deleteReservation(_ reservation: GSRReservation) {
        deleteReservation(reservation) { (successful) in
            if successful {
                guard let reservationItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.reservations]).first as? HomeReservationsCellItem else { return }
                reservationItem.reservations = reservationItem.reservations.filter { $0.bookingID != reservation.bookingID }
                if reservationItem.reservations.isEmpty {
                    self.removeItem(reservationItem)
                } else {
                    self.reloadItem(reservationItem)
                }
            }
        }
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
    func handleUrlPressed(url: String, title: String) {
        let wv = WebviewController()
        wv.load(for: url)
        wv.title = title
        navigationController?.pushViewController(wv, animated: true)
        FirebaseAnalyticsManager.shared.trackEvent(action: .viewHomeNewsArticle, result: .none, content: url)
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
        DatabaseManager.shared.trackEvent(vcName: "Dining", event: venue.name.rawValue)
        
        if let urlString = DiningDetailModel.getUrl(for: venue.name), let url = URL(string: urlString) {
            let vc = UIViewController()
            let webView = GenericWebview(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            webView.loadRequest(URLRequest(url: url))
            vc.view.addSubview(webView)
            vc.title = venue.name.rawValue
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
        let message = "Has there been a change to your schedule? If so, would you like Penn Mobile to update your courses?"
        let alert = UIAlertController(title: "Update Courses",
                                      message: message,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ (UIAlertAction) in
            //self.showCourseWebviewController()
            self.showActivity()
            PennInTouchNetworkManager.instance.getCoursesWithAuth(currentTermOnly: true, callback: self.handleNetworkCourseRefreshCompletion(_:))
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
    
    fileprivate func handleNetworkCourseRefreshCompletion(_ courses: Set<Course>?) {
        DispatchQueue.main.async {
            self.hideActivity()
            if courses == nil {
                self.showCourseWebviewController()
            } else {
                self.handleCourseRefresh(courses)
            }
        }
    }
    
    private func handleCourseRefresh(_ courses: Set<Course>?) {
        DispatchQueue.main.async {
            if let courses = courses, let courseItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.courses]).first as? HomeCoursesCellItem {
                courseItem.courses = Array(courses).filterByWeekday(for: courseItem.weekday).sorted()
                self.reloadItem(courseItem)
                self.showAlert(withMsg: "Your courses have been updated.", title: "Success!", completion: nil)
            } else {
                self.showAlert(withMsg: "Unable to access your courses. Please try again later.", title: "Uh oh!", completion: nil)
            }
        }
    }
}
