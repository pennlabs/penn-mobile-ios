//
//  GenericViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class GenericTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
        
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
        
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
        updateData()
        track(screenName)
    }
    
    func updateData() { }
    
    var screenName: String?
    
    private func track(_ name: String?) {
        if let name = name {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.set(kGAIScreenName, value: name)
            
            let builder = GAIDictionaryBuilder.createScreenView()
            if let build = builder?.build() as? [AnyHashable: Any] {
                tracker?.send(build)
            }
        }
    }
}

class GenericViewController: UIViewController {
    
    var revealController: SWRevealViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
        
        //slide out menu stuff
        revealController = SWRevealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        self.screenName = "Generic"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
        
        track(screenName)
    }
    
    var showButton: Bool = false {
        didSet {
            //Assigns function to the menu button
            if showButton {
                let revealButtonItem = UIBarButtonItem(image: UIImage(named: "reveal-icon.png")!, style: .plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
                self.navigationItem.leftBarButtonItem = revealButtonItem
            }
        }
    }
    
    var screenName: String?
    
    private func track(_ name: String?) {
        if let name = name {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.set(kGAIScreenName, value: name)
            
            let builder = GAIDictionaryBuilder.createScreenView()
            if let build = builder?.build() as? [AnyHashable: Any] {
                tracker?.send(build)
            }
        }
    }
}

