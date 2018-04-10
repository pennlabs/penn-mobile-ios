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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        view.backgroundColor = .white
        trackScreen = true
        
        prepareTableView()
        prepareRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Home"
        if tableViewModel == nil {
            fetchViewModel {
                // TODO: behavior for when model returns
            }
        } else {
            self.fetchCellSpecificData()
        }
    }
}

// MARK: - Prepare TableView
extension HomeViewController {
    func prepareTableView() {
        tableView = ModularTableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
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
}

// MARK: - ViewModelDelegate
extension HomeViewController: HomeViewModelDelegate, GSRBookable {
    
    func handleUrlPressed(_ url: String) {
    }
    
    var allowMachineNotifications: Bool {
        return true
    }
    
    func handleVenueSelected(_ venue: DiningVenue) {
        let ddc = DiningDetailViewController()
        ddc.venue = venue
        navigationController?.pushViewController(ddc, animated: true)
    }
    
    func handleBookingRequested(_ booking: GSRBooking) {
        if GSRUser.hasSavedUser() {
            booking.user = GSRUser.getUser()
            submitBooking(for: booking) { (completion) in
                print("Completed: \(completion)")
            }
        } else {
            print("No user found")
        }
    }
}

// MARK: - Networking
extension HomeViewController {
    func fetchViewModel(_ completion: @escaping () -> Void) {
        HomeAPIService.instance.fetchModel { (model) in
            guard let model = model else { return }
            DispatchQueue.main.async {
                self.setModel(model)
                self.tableView.reloadData()
                self.fetchCellSpecificData {
                    if let venue = model.venueToPreload() {
                        DiningDetailModel.preloadWebview(for: venue.name)
                    }
                }
                completion()
            }
        }
    }
    
    func fetchCellSpecificData(_ completion: (() -> Void)? = nil) {
        guard let items = tableViewModel.items as? [HomeCellItem] else { return }
        HomeAsynchronousAPIFetching.instance.fetchData(for: items, singleCompletion: { (item) in
            DispatchQueue.main.async {
                let row = items.index(where: { (thisItem) -> Bool in
                    thisItem.equals(item: item)
                })!
                let indexPath = IndexPath(row: row, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }) {
            DispatchQueue.main.async {
                completion?()
            }
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
        fetchCellSpecificData {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}
