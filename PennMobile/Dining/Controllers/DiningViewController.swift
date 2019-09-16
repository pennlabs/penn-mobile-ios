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
    
    fileprivate var isReturningFromRefreshLogin: Bool = false
        
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
        
        if viewModel.shouldShowDiningBalances {
            if viewModel.balance == nil {
                fetchBalance()
            } else {
                updateBalanceIfNeeded()
            }
        }
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
            }
        }
    }
    
    func fetchBalance() {
        self.viewModel.showActivity = true
        DiningAPI.instance.fetchDiningBalance { (diningBalance) in
            DispatchQueue.main.async {
                self.viewModel.balance = diningBalance
                self.viewModel.showActivity = false
                self.tableView.reloadData()
                self.updateBalanceIfNeeded()
            }
        }
    }
    
    func updateBalanceIfNeeded() {
        // Do not try to update the balance if the user is not authed into shibboleth
        if !UserDefaults.standard.isAuthedIn() { return }
        
        if isReturningFromRefreshLogin {
            // If returning from refresh, continue to fetch balance but set flag to FALSE
            isReturningFromRefreshLogin = false
        } else if let balance = self.viewModel.balance, balance.lastUpdated.minutesFrom(date: Date()) < 10 {
            // Do not fetch balance if the last balance was fetched less than 10 minutes ago or if
            // balance is being refetched in refreshBalance()
            return
        }
        updateBalanceFromCampusExpress()
    }
    
    func updateBalanceFromCampusExpress(_ completion: ((_ error: Error?) -> Void)? = nil) {
        self.viewModel.showActivity = true
        CampusExpressNetworkManager.instance.getDiningBalanceHTML { (html, error) in
            if let networkingError = error as? NetworkingError, networkingError == NetworkingError.authenticationError {
                UserDefaults.standard.setShibbolethAuth(authedIn: false)
            } else {
                UserDefaults.standard.setShibbolethAuth(authedIn: true)
            }
            
            if let html = html {
                UserDBManager.shared.parseAndSaveDiningBalanceHTML(html: html) { (hasPlan, balance) in
                    DispatchQueue.main.async {
                        if let hasDiningPlan = hasPlan {
                            UserDefaults.standard.set(hasDiningPlan: hasDiningPlan)
                        }
                        self.viewModel.balance = balance ?? self.viewModel.balance
                        self.viewModel.showActivity = false
                        self.tableView.reloadData()
                        completion?(error)
                    }
                }
            } else {
                completion?(error)
            }
        }
    }
}

// MARK: - UIRefreshControl
extension DiningViewController {
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshControl(_:)), for: .valueChanged)
    }
    
    @objc fileprivate func handleRefreshControl(_ sender: Any) {
        fetchDiningHours()
        if UserDefaults.standard.isAuthedIn() {
            updateBalanceFromCampusExpress()
        }
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

// MARK: - DiningBalanceRefreshable
extension DiningViewController: DiningBalanceRefreshable {
    func refreshBalance() {
        updateBalanceFromCampusExpress { (error) in
            if let error = error as? NetworkingError, error == NetworkingError.authenticationError {
                // Failed to get balance because failed to authenticate into Campus Express
                // Request user to log in again
                let pennLoginController = PennLoginController()
                let nvc = UINavigationController(rootViewController: pennLoginController)
                self.isReturningFromRefreshLogin = true
                self.present(nvc, animated: true, completion: nil)
            }
        }
    }
}
