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
    var skipButton: UIButton!
    
    fileprivate var coursesToSave: Set<Course>?
    
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
        lwc.coursesRetrieved = coursesRetreived(_:)
        let nvc = UINavigationController(rootViewController: lwc)
        present(nvc, animated: true, completion: nil)
    }
    
    @objc func handleSkip(_ sender: Any) {
        AppDelegate.shared.rootViewController.switchToMainScreen()
    }
    
    func loginCompletion(_ student: Student?) {
        if let student = student {
            // Login Successful
            print(student.description)
            UserDBManager.shared.saveStudent(student) { (accountID) in
                DispatchQueue.main.async {
                    if let accountID = accountID {
                        UserDefaults.standard.set(accountID: accountID)
                        print(accountID)
                        if let courses = self.coursesToSave {
                            UserDBManager.shared.saveCourses(courses, accountID: accountID) { (success) in
                                print(success)
                            }
                        }
                    }
                    AppDelegate.shared.rootViewController.switchToMainScreen()
                }
            }
        } else {
            showAlert(withMsg: "Something went wrong. Please try again.", title: "Uh oh!", completion: nil)
        }
    }
    
    func coursesRetreived(_ courses: Set<Course>?) {
        print("-------------All Courses--------------")
        courses?.forEach { print($0.description) }
        if let courses = courses {
            if let accountID = UserDefaults.standard.getAccountID() {
                UserDBManager.shared.saveCourses(courses, accountID: accountID) { (success) in
                    print(success)
                }
            } else {
                self.coursesToSave = courses
            }
        }
    }
}
