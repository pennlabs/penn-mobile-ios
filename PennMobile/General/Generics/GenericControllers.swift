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
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        
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
        
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        
        if trackScreen {
            trackScreen(screenName ?? title)
        }
    }
    
    var screenName: String?
    var trackScreen: Bool = false
}

