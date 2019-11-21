//
//  DiningViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import WebKit

class DiningViewController: GenericTableViewController {
        
    fileprivate var viewModel = DiningViewModel()
    fileprivate var isReturningFromLogin: Bool = false
        
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
        if viewModel.venues[.dining]?.isEmpty ?? true {
            viewModel.refresh()
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
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
                    if error {
                        self.navigationVC?.addStatusBar(text: .apiError)
                    } else {
                        self.navigationVC?.addStatusBar(text: .noInternet)
                    }
                }
                self.viewModel.venues = DiningDataStore.shared.getSectionedVenues()
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
        if let balance = self.viewModel.balance, balance.lastUpdated.hoursFrom(date: Date()) < 12 && !isReturningFromLogin {
            // Do not fetch balance if the last balance was fetched less than 12 hours ago or if balance is being refetched in refreshBalance()
            // Fetch the balance, however, if returning from login
            return
        }
        updateBalanceFromCampusExpress()
    }
    
    func updateBalanceFromCampusExpress(requestLoginOnFail: Bool = false) {
        // Do nothing if network call is being made
        if self.viewModel.showActivity { return }
        
        self.viewModel.showActivity = true
        self.tableView.reloadData()
        CampusExpressNetworkManager.instance.getDiningBalanceHTML { (html, error) in
            if let html = html {
                UserDBManager.shared.parseAndSaveDiningBalanceHTML(html: html) { (hasPlan, balance) in
                    DispatchQueue.main.async {
                        if let hasDiningPlan = hasPlan {
                            UserDefaults.standard.set(hasDiningPlan: hasDiningPlan)
                        }
                        self.viewModel.balance = balance ?? self.viewModel.balance
                        self.viewModel.showActivity = false
                        self.isReturningFromLogin = false
                        self.tableView.reloadData()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.viewModel.showActivity = false
                    self.tableView.reloadData()
                    
                    if requestLoginOnFail {
                        let wasReturningFromLogin = self.isReturningFromLogin
                        if let error = error as? NetworkingError, error == NetworkingError.authenticationError && !self.isReturningFromLogin {
                            // Failed to get balance because failed to authenticate into Campus Express
                            // Request user to log in again
                            self.showLoginController()
                        }
                        
                        if wasReturningFromLogin {
                            self.isReturningFromLogin = false
                        }
                    }
                }
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
        if viewModel.shouldShowDiningBalances {
            updateBalanceFromCampusExpress(requestLoginOnFail: true)
        }
    }
}

// MARK: - DiningViewModelDelegate
extension DiningViewController: DiningViewModelDelegate {
    func handleSelection(for venue: DiningVenue) {

        DatabaseManager.shared.trackEvent(vcName: "Dining", event: venue.name)
        
        if let url = venue.facilityURL {
            let vc = UIViewController()
            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            webView.load(URLRequest(url: url))
            vc.view.addSubview(webView)
            vc.title = venue.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - DiningBalanceRefreshable
extension DiningViewController: DiningBalanceRefreshable {
    func refreshBalance() {
        updateBalanceFromCampusExpress(requestLoginOnFail: true)
    }
}

// MARK: - Show Login Controller
extension DiningViewController {
    func showLoginController() {
        let pennLoginController = CampusExpressLoginController()
        let nvc = UINavigationController(rootViewController: pennLoginController)
        self.isReturningFromLogin = true
        self.present(nvc, animated: true, completion: nil)
    }
}
