//
//  DiningViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class DiningViewController: GenericTableViewController {
    
    fileprivate var viewModel = DiningViewModel()
    
    fileprivate let venueToPreload: DiningVenueName = .commons
    fileprivate var navigationVC: HomeNavigationController?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        self.screenName = "Dining"
        
        viewModel.delegate = self
        viewModel.registerHeadersAndCells(for: tableView)
        
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        prepareRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Dining"
        navigationVC = self.navigationController as? HomeNavigationController
        fetchDiningHours()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationVC!.hideBar(animated: false)
        refreshControl?.endRefreshing()
    }
}

//Mark: Networking to retrieve today's times
extension DiningViewController {
    fileprivate func fetchDiningHours() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DiningAPI.instance.fetchDiningHours { (success, error) in
            DispatchQueue.main.async {
                if !success {
                    DiningHoursData.shared.clearHours()
                    
                    if error {
                        self.navigationVC!.addStatusBar(text: .apiError)
                    } else {
                        self.navigationVC!.addStatusBar(text: .noInternet)
                    }
                    
                } else {
                    
                    //what to do when request is successful
                    
                }
                self.tableView.reloadData()
                
                self.refreshControl?.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

// MARK: - UIRefreshControl
extension DiningViewController {
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }
    
    @objc fileprivate func handleRefresh(_ sender: Any) {
        fetchDiningHours()
    }
}

// MARK: - DiningViewModelDelegate
extension DiningViewController: DiningViewModelDelegate {
    func handleSelection(for venue: DiningVenue) {
        //let ddc = DiningDetailViewController()
        //ddc.venue = venue
        //navigationController?.pushViewController(ddc, animated: true)
        
        UserDBManager.shared.saveDiningPreference(for: venue)
        DatabaseManager.shared.trackEvent(vcName: "Dining", event: venue.name.rawValue)
        
        if let urlString = DiningDetailModel.getUrl(for: venue.name), let url = URL(string: urlString) {
            let vc = UIViewController()
            let webView = GenericWebview(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            webView.loadRequest(URLRequest(url: url))
            vc.view.addSubview(webView)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

