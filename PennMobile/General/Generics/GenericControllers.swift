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
        //this is a test
        
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        
        //slide out menu stuff
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
        updateData()
        track(screenName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        pan(enabled: true)
    }
    
    func updateData() { }
    
    var screenName: String?
    
    func disablePan() {
        pan(enabled: false)
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
        
        //slide out menu stuff
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
        
        track(screenName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        pan(enabled: true)
    }
    
    var screenName: String?
    
    func disablePan() {
        pan(enabled: false)
    }
    
    private func pan(enabled: Bool) {
        revealViewController().panGestureRecognizer().isEnabled = enabled
    }
    
    func removeMenuButton() {
        self.navigationItem.leftBarButtonItem = nil
    }
}

