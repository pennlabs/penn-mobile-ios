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
    
    var loginButton: UIButton!
    
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
    
    func handleLogin(_ sender: Any) {
        let lwc = LoginWebviewController()
        lwc.loginCompletion = loginCompletion(_:)
        lwc.coursesRetrieved = coursesRetreived(_:)
        let nvc = UINavigationController(rootViewController: lwc)
        present(nvc, animated: true, completion: nil)
    }
    
    func loginCompletion(_ student: Student?) {
        if let student = student {
            // Login Successful
            print(student.description)
            AppDelegate.shared.rootViewController.switchToMainScreen()
        } else {
            showAlert(withMsg: "Something went wrong. Please try again.", title: "Uh oh!", completion: nil)
        }
    }
    
    func coursesRetreived(_ courses: Set<Course>?) {
        print("-------------All Courses--------------")
        courses?.forEach { print($0.description) }
    }
}
