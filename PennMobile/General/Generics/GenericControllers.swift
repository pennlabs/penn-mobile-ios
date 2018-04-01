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
        
        let revealController = SWRevealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        
        //Assigns function to the menu button
        let revealButtonItem = UIBarButtonItem(image: UIImage(named: "reveal-icon.png")!, style: .plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = revealButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        
        if trackScreen {
            trackScreen(screenName)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        pan(enabled: true)
    }
    
    var screenName: String?
    
    var trackScreen: Bool = false
    
    var isPanEnabled: Bool = true {
        didSet {
            pan(enabled: isPanEnabled)
        }
    }
    
    private func pan(enabled: Bool) {
        revealViewController().panGestureRecognizer().isEnabled = enabled
    }
}

class GenericViewController: UIViewController, Trackable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        
        let revealController = SWRevealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        
        //Assigns function to the menu button
        let revealButtonItem = UIBarButtonItem(image: UIImage(named: "reveal-icon.png")!, style: .plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = revealButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        
        if trackScreen {
            trackScreen(screenName ?? title)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        pan(enabled: true)
    }
    
    var screenName: String?
    
    var trackScreen: Bool = false
    
    var isPanEnabled: Bool = true {
        didSet {
            pan(enabled: isPanEnabled)
        }
    }
    
    private func pan(enabled: Bool) {
        revealViewController()?.panGestureRecognizer().isEnabled = enabled
    }
    
    func removeMenuButton() {
        self.navigationItem.leftBarButtonItem = nil
    }
}

