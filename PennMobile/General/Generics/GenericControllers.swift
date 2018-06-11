//
//  GenericViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

@objc class GenericTableViewController: UITableViewController, Trackable {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = screenName
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
        
        if trackScreen {
            trackScreen(screenName)
        }
    }
    
    var screenName: String?
    var trackScreen: Bool = false
}

class GenericViewController: UIViewController, Trackable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = screenName
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        
        if trackScreen {
            trackScreen(screenName ?? title)
        }
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

