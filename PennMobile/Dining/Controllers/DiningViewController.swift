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
        fetchDiningHours()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl?.endRefreshing()
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        self.tabBarController?.title = "Dining"
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
                        self.navigationVC?.addStatusBar(text: .apiError)
                    } else {
                        self.navigationVC?.addStatusBar(text: .noInternet)
                    }
                    
                } else {
                    
                    //what to do when request is successful
                    
                }
                self.tableView.reloadData()
                
                self.refreshControl?.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.updateBalance()
            }
        }
    }
    
    func updateBalance() {
        if let balance = self.viewModel.balance, balance.lastUpdated.minutesFrom(date: Date()) < 10 {
            return
        }
        
        self.viewModel.showActivity = true
        CampusExpressNetworkManager.instance.getDiningData { (diningBalance) in
            DispatchQueue.main.async {
                self.viewModel.balance = diningBalance
                self.viewModel.showActivity = false
                self.tableView.reloadData()
                
                if let diningBalance = diningBalance {
                    UserDBManager.shared.saveDiningBalance(for: diningBalance)
                }
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
}

