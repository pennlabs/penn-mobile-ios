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
        
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBlue
        
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
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBlue
        
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

