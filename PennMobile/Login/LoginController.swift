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
    
    fileprivate var backgroundImage: UIImageView!
    
    fileprivate var iconShadow: CAShapeLayer!
    fileprivate var icon: UIImageView!
    fileprivate var titleLabel: UILabel!
    
    fileprivate var loginShadow: CAShapeLayer!
    fileprivate var loginGradient: CAGradientLayer!
    fileprivate var loginButton: UIButton!
    
    fileprivate var skipShadow: CAShapeLayer!
    fileprivate var skipButton: UIButton!
    
    fileprivate var isFirstAttempt = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .uiBackground
        prepareUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginGradient.frame = loginButton.bounds
        loginButton.layer.insertSublayer(loginGradient, at: 0)
        
        loginShadow.path = UIBezierPath(roundedRect: loginButton.bounds, cornerRadius: 20).cgPath
        loginShadow.shadowPath = loginShadow.path
        loginButton.layer.insertSublayer(loginShadow, at: 0)
        
        skipShadow.path = UIBezierPath(roundedRect: skipButton.bounds, cornerRadius: 20).cgPath
        skipShadow.shadowPath = skipShadow.path
        skipButton.layer.insertSublayer(skipShadow, at: 0)
    }
}

// MARK: - Login Completion Handler
extension LoginController {
    func loginCompletion(_ successful: Bool) {
        if successful {
            // Login Successful
            AppDelegate.shared.rootViewController.switchToMainScreen()
            
            AppDelegate.shared.rootViewController.requestPermissions()
            
        } else {
            // Failed to retrieve Account from Platform (possibly down)
            if !self.isFirstAttempt {
                AppDelegate.shared.rootViewController.switchToMainScreen()
            } else {
                self.isFirstAttempt = false
            }
            HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
        }
    }
}

// MARK: - Login and Skip Button Pressed Handlers {
extension LoginController {
    @objc fileprivate func handleLogin(_ sender: Any) {
        let lwc = LabsLoginController { (success) in
            self.loginCompletion(success)
        }
        let nvc = UINavigationController(rootViewController: lwc)
        present(nvc, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSkip(_ sender: Any) {
        AppDelegate.shared.rootViewController.switchToMainScreen()
        FirebaseAnalyticsManager.shared.trackEvent(action: "Selected Continue as Guest", result: "Selected Continue as Guest", content: "Selected Continue as Guest")
    }
}

// MARK: - Prepare UI
extension LoginController {
    fileprivate func prepareUI() {
        prepareBackgroundImage()
        prepareLoginButton()
        prepareSkipButton()
        prepareIcon()
        prepareTitleLabel()
    }
    
    fileprivate func prepareBackgroundImage() {
        let iconImage: UIImage = UIImage(named: "LoginBackground")!
        backgroundImage = UIImageView(image: iconImage)
        backgroundImage.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImage)
        backgroundImage.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    fileprivate func prepareLoginButton() {
        loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = false
        
        // Add drop shadow
        loginShadow = CAShapeLayer()
        loginShadow.fillColor = UIColor.white.cgColor
        loginShadow.shadowColor = UIColor.grey1.cgColor
        loginShadow.shadowOffset = CGSize(width: 0.5, height: 1.5)
        loginShadow.shadowOpacity = 0.5
        loginShadow.shadowRadius = 2
        
        // Add gradient
        let color1 = UIColor(r: 11, g: 138, b: 204)
        let color2 = UIColor(r: 26, g: 142, b: 221)
        let color3 = UIColor(r: 31, g: 120, b: 206)
        
        loginGradient = CAGradientLayer()
        loginGradient.cornerRadius = 20
        loginGradient.locations = [0, 0.3, 1]
        loginGradient.startPoint = CGPoint(x: 0, y: 0)
        loginGradient.endPoint = CGPoint(x: 1, y: 0)
        loginGradient.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        
        let attributedString = NSMutableAttributedString(string: "LOG IN WITH PENNKEY")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
        
        loginButton.setAttributedTitle(attributedString, for: .normal)
        loginButton.titleLabel?.font = UIFont.avenirMedium.withSize(15)
        loginButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    fileprivate func prepareSkipButton() {
        let buttonColor = UIColor(r: 31, g: 120, b: 206)
        skipButton = UIButton(type: .system)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.backgroundColor = .white
        skipButton.layer.cornerRadius = 20
        skipButton.layer.borderWidth = 1.5
        skipButton.layer.borderColor = buttonColor.cgColor
        
        // Add drop shadow
        skipShadow = CAShapeLayer()
        skipShadow.fillColor = UIColor.white.cgColor
        skipShadow.shadowColor = UIColor.grey1.cgColor
        skipShadow.shadowOffset = CGSize(width: 0.5, height: 1)
        skipShadow.shadowOpacity = 0.5
        skipShadow.shadowRadius = 1
        
        let attributedString = NSMutableAttributedString(string: "CONTINUE AS GUEST")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: buttonColor, range: NSRange(location: 0, length: attributedString.length))
        
        skipButton.setAttributedTitle(attributedString, for: .normal)
        skipButton.titleLabel?.font = UIFont.avenirMedium.withSize(15)
        skipButton.addTarget(self, action: #selector(handleSkip(_:)), for: .touchUpInside)
        
        view.addSubview(skipButton)
        skipButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30).isActive = true
        skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        skipButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor).isActive = true
        skipButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
    }
    
    fileprivate func prepareIcon() {
        let iconImage: UIImage = UIImage(named: "LaunchIcon")!
        icon = UIImageView(image: iconImage)
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        // Add drop shadow
        icon.layer.shadowColor = UIColor.grey1.cgColor
        icon.layer.shadowOffset = CGSize(width: 1, height: 2)
        icon.layer.shadowOpacity = 0.5
        icon.layer.shadowRadius = 1.0
        icon.clipsToBounds = false
        
        view.addSubview(icon)
        icon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -150).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 80).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    fileprivate func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.avenirMedium.withSize(25)
        titleLabel.textColor = .labelPrimary
        titleLabel.textAlignment = .center
        titleLabel.text = "Penn Mobile"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12).isActive = true
    }
}
