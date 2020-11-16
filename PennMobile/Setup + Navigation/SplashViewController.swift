//
//  SplashViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/25/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import FirebaseCore

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        switchToView()
    }
    
    private func switchToView() {
        let loggedIn = UserDefaults.standard.getAccountID() != nil
        if loggedIn {
            AppDelegate.shared.rootViewController.showMainScreen()
        } else {
            AppDelegate.shared.rootViewController.showLoginScreen()
        }
    }
}
