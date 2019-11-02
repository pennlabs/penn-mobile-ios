//
//  GenericViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

@objc class GenericTableViewController: UITableViewController, Trackable {
    
    var navigationVC: HomeNavigationController?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationVC?.navigationBar.tintColor = UIColor.navigation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationVC = self.navigationController as? HomeNavigationController
        navigationVC?.navigationBar.tintColor = UIColor.navigation
        
        if trackScreen {
            trackScreen(screenName)
        }
        
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationVC?.hideBar(animated: false)
    }
    
    func setupNavBar() {
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    var screenName: String?
    var trackScreen: Bool = false
}

class GenericViewController: UIViewController, Trackable {
    
    var navigationVC: HomeNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .uiBackground
        navigationVC = navigationController as? HomeNavigationController
        navigationVC?.navigationBar.tintColor = UIColor.navigation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationVC?.navigationBar.tintColor = UIColor.navigation
        
        if trackScreen {
            trackScreen(screenName ?? title)
        }
        
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationVC?.hideBar(animated: false)
    }
    
    func setupNavBar() {
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    var screenName: String?
    var trackScreen: Bool = false
    
    var isPanEnabled: Bool = true {
        didSet {
            //pan(enabled: isPanEnabled)
        }
    }
    
    /*private func pan(enabled: Bool) {
        revealViewController()?.panGestureRecognizer().isEnabled = enabled
    }*/
    
    func removeMenuButton() {
        self.navigationItem.leftBarButtonItem = nil
    }
}

