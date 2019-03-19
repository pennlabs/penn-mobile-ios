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
    
    fileprivate var loginShadow: CAShapeLayer!
    fileprivate var loginGradient: CAGradientLayer!
    fileprivate var loginButton: UIButton!
    
    fileprivate var skipShadow: CAShapeLayer!
    fileprivate var skipButton: UIButton!
    
    fileprivate var isFirstAttempt = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        prepareUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginGradient.frame = loginButton.bounds
        loginButton.layer.insertSublayer(loginGradient, at: 0)
        
        loginShadow.path = UIBezierPath(roundedRect: loginButton.bounds, cornerRadius: 20).cgPath
        loginShadow.shadowPath = loginShadow.path
        loginButton.layer.insertSublayer(loginShadow, at: 0)
        
        skipShadow.path = UIBezierPath(roundedRect: loginButton.bounds, cornerRadius: 20).cgPath
        skipShadow.shadowPath = loginShadow.path
        skipButton.layer.insertSublayer(skipShadow, at: 0)
    }
}

// MARK: - Login Completion Handler
extension LoginController {
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
                        self.showAlert(withMsg: "Unable to connect to Penn servers. Please try again.", title: "Uh oh!", completion: nil)
                        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
                        self.isFirstAttempt = false
                    }
                }
            }
        }
    }
}

// MARK: - Login and Skip Button Pressed Handlers {
extension LoginController {
    @objc fileprivate func handleLogin(_ sender: Any) {
        let lwc = LoginWebviewController()
        lwc.loginCompletion = loginCompletion(_:)
        let nvc = UINavigationController(rootViewController: lwc)
        present(nvc, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSkip(_ sender: Any) {
        AppDelegate.shared.rootViewController.switchToMainScreen()
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
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = false
        
        // Add drop shadow
        loginShadow = CAShapeLayer()
        loginShadow.fillColor = UIColor.white.cgColor
        loginShadow.shadowColor = UIColor.darkGray.cgColor
        loginShadow.shadowOffset = CGSize(width: 1.0, height: 2.0)
        loginShadow.shadowOpacity = 0.8
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
        loginButton.titleLabel?.font = UIFont.avenirMedium?.withSize(15)
        loginButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 260).isActive = true
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
        skipShadow.shadowColor = UIColor.darkGray.cgColor
        skipShadow.shadowOffset = CGSize(width: 0.5, height: 1)
        skipShadow.shadowOpacity = 0.5
        skipShadow.shadowRadius = 1
        
        let attributedString = NSMutableAttributedString(string: "CONTINUE AS GUEST")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: buttonColor, range: NSRange(location: 0, length: attributedString.length))
        
        skipButton.setAttributedTitle(attributedString, for: .normal)
        skipButton.titleLabel?.font = UIFont.avenirMedium?.withSize(15)
        skipButton.addTarget(self, action: #selector(handleSkip(_:)), for: .touchUpInside)
        
        view.addSubview(skipButton)
        skipButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30).isActive = true
        skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 260).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}

/**
 * View with a gradient layer.
 */
class GradientView: UIView {
    
    let gradient : CAGradientLayer
    
    init(gradient: CAGradientLayer) {
        self.gradient = gradient
        super.init(frame: .zero)
        self.gradient.frame = self.bounds
        self.layer.insertSublayer(self.gradient, at: 0)
    }
    
    convenience init(colors: [UIColor], locations:[Float] = [0.0, 1.0]) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations.map { NSNumber(value: $0) }
        self.init(gradient: gradient)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.gradient.frame = self.bounds
    }
    
    required init?(coder: NSCoder) { fatalError("no init(coder:)") }
}
