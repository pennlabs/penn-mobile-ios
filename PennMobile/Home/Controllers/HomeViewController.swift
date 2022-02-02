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

    static let edgeSpacing: CGFloat = Padding.pad
    static let cellSpacing: CGFloat = Padding.pad * 2

    static let refreshInterval: Int = 10

    var lastRefresh: Date = Date()

    var loadingView: UIActivityIndicatorView!

    fileprivate var barButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        screenName = "Home"
        view.backgroundColor = .uiBackground

        prepareLoadingView()
        prepareTableView()
        prepareRefreshControl()

        registerForNotifications()

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false

        if tableViewModel == nil {
            self.startLoadingViewAnimation()
        }
        self.refreshTableView {
            self.stopLoadingViewAnimation()
        }
    }

    override func setupNavBar() {
        super.setupNavBar()
        self.tabBarController?.title = getTitle()
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
    }

    fileprivate var titleCacheTimestamp = Date()
    fileprivate var displayTitle: String?

    fileprivate func getTitle() -> String? {
        let now = Date()
        if titleCacheTimestamp.minutesFrom(date: now) <= 60 && self.displayTitle != nil {
            return self.displayTitle
        } else {
            let firstName = Account.getAccount()?.first

            let intros = ["Welcome", "Howdy", "Hi there", "Hello", "Greetings", "Sup"]

            if let firstName = firstName, firstName != "" {
                self.displayTitle = "\(intros.random!), \(firstName)!"
                titleCacheTimestamp = Date()
            } else {
                self.displayTitle = "\(intros.random!)!"
            }

            return self.displayTitle
        }
    }

    func clearCache() {
        displayTitle = nil
        tableViewModel = nil
    }

    func clearCacheAndReload(animated: Bool) {
        if animated {
            self.startLoadingViewAnimation()
        }
        clearCache()
        refreshTableView {
            if animated {
                self.stopLoadingViewAnimation()
            }
        }
    }
}

// MARK: - Home Page Networking
extension HomeViewController {
    fileprivate func refreshTableView(forceRefresh: Bool = false, _ completion: (() -> Void)? = nil) {
        let now = Date()
        if forceRefresh || tableViewModel == nil || now > lastRefresh.add(minutes: HomeViewController.refreshInterval) {
            fetchViewModel {
                self.lastRefresh = Date()
                completion?()
            }
        } else {
            completion?()
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
        tableView?.model = tableViewModel
    }

    func prepareLoadingView() {
        loadingView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        loadingView.color = .black
        loadingView.isHidden = false
        view.addSubview(loadingView)
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
    }

    func startLoadingViewAnimation() {
        if loadingView != nil && !loadingView.isHidden {
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

// MARK: - Networking
extension HomeViewController {
    func fetchViewModel(_ completion: @escaping () -> Void) {
        HomeAPIService.instance.fetchModel { model in
            self.setModel(model)

            UIView.transition(with: self.tableView,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData() })

            completion()
        }
    }

    func reloadItem(_ item: HomeCellItem) {
        guard let allItems = tableViewModel?.items as? [HomeCellItem] else { return }
        if let row = allItems.firstIndex(where: { (thisItem) -> Bool in
            thisItem.equals(item: item)
        }) {
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    func removeItem(_ item: HomeCellItem) {
        guard let allItems = tableViewModel?.items as? [HomeCellItem] else { return }
        if let row = allItems.firstIndex(where: { (thisItem) -> Bool in
            thisItem.equals(item: item)
        }) {
            let indexPath = IndexPath(row: row, section: 0)
            tableViewModel.items.remove(at: row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
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
        self.refreshTableView(forceRefresh: true) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension HomeViewController : DiningCellSettingsDelegate {
    func saveSelection(for venueIds: [Int]) {
        guard let diningItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.dining]).first as? HomeDiningCellItem else { return }
        if venueIds.count == 0 {
            diningItem.venues = DiningAPI.instance.getVenues(with: DiningVenue.defaultVenueIds)
        } else {
            diningItem.venues = DiningAPI.instance.getVenues(with: venueIds)
        }

        reloadItem(diningItem)
        UserDBManager.shared.saveDiningPreference(for: venueIds)
    }
}

// MARK: - Notification Updating
extension HomeViewController {
    @objc fileprivate func updateLaundryItemForPreferences(_ sender: Notification) {
        if let laundryRooms = sender.object as? [LaundryRoom] {
            if laundryRooms.count == 0 {
                if let laundryItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.laundry]).first {
                    removeItem(laundryItem)
                }
            } else {
                if let laundryItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.laundry]).first {
                    (laundryItem as? HomeLaundryCellItem)?.room = laundryRooms[0]
                    reloadItem(laundryItem)
                } else {
                    tableViewModel.items.append(HomeLaundryCellItem(room: laundryRooms[0]))
                    self.tableView.reloadData()
                }
            }
        }
    }

    // TODO: update GSR reservation cell immediately after a booking is made
//    @objc fileprivate func addGSRReservation(_ sender: Notification) {
//        guard let reservation = sender.object as? GSRReservation else { return }
//
//        guard let reservationItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.reservations]).first as? HomeReservationsCellItem else {
//            tableViewModel.items.insert(HomeReservationsCellItem(for: [reservation]), at: 0)
//            tableView.reloadData()
//            return
//        }
//
//        reservationItem.reservations.append(reservation)
//        reservationItem.reservations = reservationItem.reservations.sorted(by: { $0.start < $1.start })
//        reloadItem(reservationItem)
//    }
}

// MARK: - Register for Notifications
extension HomeViewController {
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLaundryItemForPreferences(_:)), name: Notification.Name(rawValue: "LaundryUpdateNotification"), object: nil)
    }
}
