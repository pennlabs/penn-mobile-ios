//
//  LoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/25/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class LoginController: UIViewController, ShowsAlert {
    
    fileprivate var loginButton: UIButton!
    fileprivate var skipButton: UIButton!
    
    fileprivate var isFirstAttempt = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        prepareUI()
    }
}

// MARK: - Prepare UI
extension LoginController {
    fileprivate func prepareUI() {
        prepareLoginButton()
        prepareSkipButton()
    }
    
    fileprivate func prepareLoginButton() {
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(UIColor.buttonBlue, for: .normal)
        loginButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func prepareSkipButton() {
        skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(UIColor.buttonBlue, for: .normal)
        skipButton.addTarget(self, action: #selector(handleSkip(_:)), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(skipButton)
        skipButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30).isActive = true
        skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func handleLogin(_ sender: Any) {
        let lwc = LoginWebviewController()
        lwc.loginCompletion = loginCompletion(_:)
        let nvc = UINavigationController(rootViewController: lwc)
        present(nvc, animated: true, completion: nil)
    }
    
    @objc func handleSkip(_ sender: Any) {
        AppDelegate.shared.rootViewController.switchToMainScreen()
    }
    
    func loginCompletion(_ successful: Bool) {
        if successful {
            // Login Successful
            AppDelegate.shared.rootViewController.switchToMainScreen()
        } else if UserDefaults.standard.getStudent() != nil {
            // Successfully retrieved Student profile from PennInTouch but failed to send to DB
            AppDelegate.shared.rootViewController.switchToMainScreen()
        } else {
            // Failed to retrieve Student profile from PennInTouch (possibly down)
            GSRNetworkManager.instance.getSessionID { (success) in
                DispatchQueue.main.async {
                    // Get Wharton Session ID
                    if success || !self.isFirstAttempt {
                        AppDelegate.shared.rootViewController.switchToMainScreen()
                    } else {
                        self.showAlert(withMsg: "Something went wrong. Please try again.", title: "Uh oh!", completion: nil)
                        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
                        self.isFirstAttempt = false
                    }
                }
            }
        }
    }
}
