//
//  AboutViewController.swift
//  GSR
//
//  Created by Yagil Burowski on 04/10/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

class GSRAboutViewController: GAITrackedViewController, ShowsAlert {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set screen name.
        self.screenName = "About Screen"
        
        // Do any additional setup after loading the view.
    }
    
    
    internal func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    internal func cancel(_ sender: AnyObject) {
        dismiss()
    }
    
    
    
    internal func resetCredentials() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "password")
        self.showAlert(withMsg: "You've successfuly reset your credentials. They are no longer stored on this device.", title: "Reset Credentials", completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
