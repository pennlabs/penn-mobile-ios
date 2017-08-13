//
//  CredentialsViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 4/20/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class CredentialsViewController: GAITrackedViewController, ShowsAlert, IndicatorEnabled {
    
    var date : GSRDate?
    var location : GSRLocation?
    var ids : [Int]?
    var email : String?
    var password : String?
    
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Penn email (e.g. amyg@sas.upenn.edu)"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = .emailAddress
        tf.textAlignment = .natural
        tf.borderStyle = .roundedRect
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "PennKey Password"
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .natural
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let message: UITextView = {
        let tf = UITextView()
        tf.text = "Your details will be stored locally on your device. The only time they are sent over the internet is to Penn's servers for authentication. This happens via HTTPS. \n \nSpecial thanks to Yagil Burowski '17 for developing and donating the backend of this feature to PennLabs."
        tf.textColor = UIColor.lightGray
        tf.isScrollEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    private let edgeOffset: CGFloat = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.becomeFirstResponder()
        
        self.screenName = "Credentials Screen"
        navigationItem.title = "Email & Password"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCredentials(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancel(_:)))
        
        setupView()
    }
    
    private func setupView() {
        let navigationHeight = navigationController?.navigationBar.bounds.height ?? 0
        
        view.backgroundColor = .white
        
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(message)
        
        _ = emailField.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: navigationHeight + 50
            , leftConstant: edgeOffset, bottomConstant: 0, rightConstant: edgeOffset, widthConstant: 0, heightConstant: 44)
        
        _ = passwordField.anchor(emailField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: edgeOffset, bottomConstant: 0, rightConstant: edgeOffset, widthConstant: 0, heightConstant: 44)
        
        _ = message.anchor(passwordField.bottomAnchor, left: passwordField.leftAnchor, bottom: nil, right: passwordField.rightAnchor, topConstant: 30, leftConstant: -2, bottomConstant: 0, rightConstant: -8, widthConstant: 0, heightConstant: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailField.resignFirstResponder()
    }

    func saveCredentials(_ sender: AnyObject) {
        email = emailField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        password = passwordField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        
        guard let email = email, let password = password else { return }
        if (email == "" || password == "" || !email.contains("@") || !email.contains("upenn.edu")) {
            handleErrorAuthenticating()
            return
        }
        
        let defaults = UserDefaults.standard

        if email != defaults.string(forKey: "email") || password != defaults.string(forKey: "password") {
            showActivity()
        }
        
        GSRNetworkManager.shared.authenticateEmailPassword(email: email, password: password) { (isValid) in
            self.hideActivity()
            
            if isValid {
                defaults.setValue(email, forKey: "email")
                defaults.setValue(password, forKey: "password")
                
                self.emailField.resignFirstResponder()
                self.passwordField.resignFirstResponder()
                
                if self.date == nil {
                    self.dismiss()
                } else {
                    self.showProcessViewController()
                }
            } else {
                self.handleErrorAuthenticating()
            }
            
            GoogleAnalyticsManager.shared.trackEvent(category: "Study Room Booking", action: "Attempted login", label: (isValid ? "Success" : "Failed"), value: 1)
        }
    }
    
    func handleErrorAuthenticating() {
        showAlert(withMsg: "Your email or password is invalid. Please try again.", title: "Uh oh!", completion: nil)
    }
    
    func cancel(_ sender: AnyObject) {
        self.emailField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
        dismiss()
    }
    
    internal func showProcessViewController() {
        let dest = ProcessViewController()
        dest.ids = ids
        dest.date = date
        dest.location = location
        dest.email = email
        dest.password = password
        
        navigationController?.pushViewController(dest, animated: true)
    }
    
    internal func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
