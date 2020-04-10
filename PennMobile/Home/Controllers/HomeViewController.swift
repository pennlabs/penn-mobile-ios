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
        view.backgroundColor = .uiBackground
        trackScreen = true

        prepareLoadingView()
        prepareTableView()
        prepareRefreshControl()

        registerForNotifications()

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            let firstName = Account.getAccount()?.first ?? GSRUser.getUser()?.firstName
            if let firstName = firstName {
                let intros = ["Welcome", "Howdy", "Hi there", "Hello", "Greetings", "Sup"]
                self.displayTitle = "\(intros.random!), \(firstName)!"
                titleCacheTimestamp = Date()
            } else {
                self.displayTitle = "Home"
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
    fileprivate func refreshTableView(_ completion: (() -> Void)? = nil) {
        let now = Date()
        if tableViewModel == nil || now > lastRefresh.add(minutes: HomeViewController.refreshInterval) {
            fetchViewModel {
                self.lastRefresh = Date()
                completion?()
            }
        } else {
            // Reload visibile cell, then get data for each cell, and reload again
            self.tableView.reloadData()
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
        tableView?.model = tableViewModel
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
    func fetchViewModel(_ secondAttempt: Bool = false, _ completion: @escaping () -> Void) {
        HomeAPIService.instance.fetchModel { (model, error) in
            DispatchQueue.main.async {
                if error != nil {
                    let navigationVC = self.navigationController as? HomeNavigationController

                    if !secondAttempt {
                        self.fetchViewModel(true, completion)
                    } else {
                        navigationVC?.addStatusBar(text: .apiError)
                        completion()
                    }
                    return
                }
                
                guard let model = model else { return }
                self.setModel(model)
                UIView.transition(with: self.tableView,
                                  duration: 0.35,
                                  options: .transitionCrossDissolve,
                                  animations: { self.tableView.reloadData() })
                self.fetchAllCellData {
                    // Do anything here that needs to be done after all the cells are loaded
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
        guard let allItems = tableViewModel?.items as? [HomeCellItem] else { return }
        if let row = allItems.firstIndex(where: { (thisItem) -> Bool in
            thisItem.equals(item: item)
        }) {
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
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
        self.refreshTableView {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension HomeViewController : DiningCellSettingsDelegate {
    func saveSelection(for venueIds: [Int]) {
        guard let diningItem = self.tableViewModel.getItems(for: [HomeItemTypes.instance.dining]).first as? HomeDiningCellItem else { return }
        if venueIds.count == 0 {
            diningItem.venues = DiningDataStore.shared.getVenues(for: DiningVenue.defaultVenueIds)
            diningItem.venueIds = DiningVenue.defaultVenueIds
        } else {
            diningItem.venues = DiningDataStore.shared.getVenues(for: venueIds)
            diningItem.venueIds = venueIds
        }

        reloadItem(diningItem)
        self.fetchCellData(for: [diningItem])
        UserDBManager.shared.saveDiningPreference(for: venueIds)
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
