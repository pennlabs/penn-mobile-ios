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
        FirebaseApp.configure()
        ControllerModel.shared.prepare()
        LaundryNotificationCenter.shared.prepare()
        GSRLocationModel.shared.prepare()
        LaundryAPIService.instance.prepare {
            DispatchQueue.main.async {
                self.switchToView()
            }
        }
    }
    
    private func switchToView() {
        let loggedIn = false
        if loggedIn {
            //AppDelegate.shared.rootViewController.switchToMainScreen()
        } else {
            AppDelegate.shared.rootViewController.showLoginScreen()
        }
    }
}
