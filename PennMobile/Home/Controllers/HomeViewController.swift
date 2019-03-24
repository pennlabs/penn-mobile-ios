//
//  HomeViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: GenericViewController {

    var tableViewModel: HomeTableViewModel!
    var tableView: ModularTableView!

    static let edgeSpacing: CGFloat = 20
    static let cellSpacing: CGFloat = 20
    
    static let refreshInterval: Int = 10
    
    var lastRefresh: Date = Date()
    
    var loadingView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        view.backgroundColor = .white
        trackScreen = true
        
        prepareLoadingView()
        prepareTableView()
        prepareRefreshControl()
        
        registerForNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Home"
        if tableViewModel == nil {
            self.startLoadingViewAnimation()
        }
        self.refreshTableView {
            self.stopLoadingViewAnimation()
        }
    }
}

// MARK: - Home Page Networking
extension HomeViewController {
    fileprivate func refreshTableView(_ completion: (() -> Void)? = nil) {
        let now = Date()
        if tableViewModel == nil || now > lastRefresh.add(minutes: HomeViewController.refreshInterval) {
            fetchViewModel {
                self.lastRefresh = Date()
                completion?()
            }
        } else {
            self.fetchAllCellData(completion)
        }
    }
}

// MARK: - Prepare TableView
extension HomeViewController {
    func prepareTableView() {
        tableView = ModularTableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isHidden = true // Initially while loading

        view.addSubview(tableView)

        tableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }

        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 30.0))

        HomeItemTypes.instance.registerCells(for: tableView)
    }

    func setModel(_ model: HomeTableViewModel) {
        tableViewModel = model
        tableViewModel.delegate = self
        tableView.model = tableViewModel
    }
    
    func prepareLoadingView() {
        loadingView = UIActivityIndicatorView(style: .whiteLarge)
        loadingView.color = .black
        loadingView.isHidden = false
        view.addSubview(loadingView)
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func startLoadingViewAnimation() {
        if !loadingView.isHidden {
            loadingView.startAnimating()
        }
    }
    
    func stopLoadingViewAnimation() {
        if tableView.isHidden {
            self.tableView.isHidden = false
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
        }
    }
}

// MARK: - ViewModelDelegate
extension HomeViewController: HomeViewModelDelegate, GSRBookable, GSRDeletable {
    func deleteReservation(_ reservation: GSRReservation) {
        deleteReservation(reservation) { (successful) in
            if successful {
                guard let reservationItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.reservations]).first as? HomeReservationsCellItem else { return }
                reservationItem.reservations = reservationItem.reservations.filter { $0.bookingID != reservation.bookingID }
                self.reloadItem(reservationItem)
            }
        }
    }
    
    func handleUrlPressed(url: String, title: String) {
        let wv = WebviewController()
        wv.load(for: url)
        wv.title = title
        navigationController?.pushViewController(wv, animated: true)
        FirebaseAnalyticsManager.shared.trackEvent(action: .viewHomeNewsArticle, result: .none, content: url)
    }

    var allowMachineNotifications: Bool {
        return true
    }

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

    func handleBookingSelected(_ booking: GSRBooking) {
        confirmBookingWanted(booking)
    }

    func handleSettingsTapped(venues: [DiningVenue]) {
        let diningSettings = DiningCellSettingsController()
        diningSettings.setupFromVenues(venues: venues)
        diningSettings.delegate = self
        let nvc = UINavigationController(rootViewController: diningSettings)
        showDetailViewController(nvc, sender: nil)
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

// MARK: - Networking
extension HomeViewController {
    func fetchViewModel(_ completion: @escaping () -> Void) {
        HomeAPIService.instance.fetchModel { (model, error) in
            DispatchQueue.main.async {
                if error != nil {
                    let navigationVC = self.navigationController as? HomeNavigationController
                    navigationVC?.addPermanentStatusBar(text: error == NetworkingError.noInternet ? StatusBar.StatusBarText.noInternet : .apiError)
                    completion()
                    return
                }
                guard let model = model else { return }
                self.setModel(model)
                UIView.transition(with: self.tableView,
                                  duration: 0.35,
                                  options: .transitionCrossDissolve,
                                  animations: { self.tableView.reloadData() })
                self.fetchAllCellData {
                    if let venue = model.venueToPreload() {
                        DiningDetailModel.preloadWebview(for: venue.name)
                    }
                }
                completion()
            }
        }
    }

    func fetchAllCellData(_ completion: (() -> Void)? = nil) {
        fetchCellData(for: HomeItemTypes.instance.getAllTypes(), completion)
    }

    func fetchCellData(for itemTypes: [HomeCellItem.Type], _ completion: (() -> Void)? = nil) {
        let items = tableViewModel.getItems(for: itemTypes)
        self.fetchCellData(for: items, completion)
    }

    func fetchCellData(for items: [HomeCellItem], _ completion: (() -> Void)? = nil) {
        HomeAsynchronousAPIFetching.instance.fetchData(for: items, singleCompletion: { (item) in
            DispatchQueue.main.async {
                self.reloadItem(item)
            }
        }) {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func reloadItem(_ item: HomeCellItem) {
        guard let allItems = tableViewModel.items as? [HomeCellItem] else { return }
        if let row = allItems.index(where: { (thisItem) -> Bool in
            thisItem.equals(item: item)
        }) {
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

// MARK: - Refreshing
extension HomeViewController {
    fileprivate func prepareRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }

    @objc fileprivate func handleRefresh(_ sender: Any) {
        self.refreshTableView {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension HomeViewController : DiningCellSettingsDelegate {
    func saveSelection(for cafes: [DiningVenue]) {
        guard let diningItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.dining]).first as? HomeDiningCellItem else { return }
        if cafes.count == 0 {
            diningItem.venues = DiningVenue.getDefaultVenues()
        } else {
            diningItem.venues = cafes
        }

        reloadItem(diningItem)
        self.fetchCellData(for: [diningItem])
        UserDBManager.shared.saveDiningPreference(for: cafes)
    }
}

// MARK: - Laundry Updating
extension HomeViewController {
    @objc fileprivate func updateLaundryItemForPreferences(_ sender: Any) {
        var preferences = LaundryRoom.getPreferences()
        guard let laundryItems = self.tableViewModel.getItems(for: [HomeItemTypes.instance.laundry]) as? [HomeLaundryCellItem] else { return }
        var outdatedItems = [HomeLaundryCellItem]()
        for item in laundryItems {
            if preferences.contains(item.room) {
                preferences.remove(at: preferences.firstIndex(of: item.room)!)
            } else {
                outdatedItems.append(item)
            }
        }
        
        for i in 0..<(outdatedItems.count) {
            if i < preferences.count {
                outdatedItems[i].room = preferences[i]
            }
        }
        
        self.fetchCellData(for: [HomeItemTypes.instance.laundry])
    }
}

// MARK: - Register for Notifications
extension HomeViewController {
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLaundryItemForPreferences(_:)), name: Notification.Name(rawValue: "LaundryUpdateNotification") , object: nil)
    }
}


