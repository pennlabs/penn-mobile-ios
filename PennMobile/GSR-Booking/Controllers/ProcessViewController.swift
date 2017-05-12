//
//  ProcessViewController.swift
//  GSR
//
//  Created by Yagil Burowski on 04/10/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit
import Google

class ProcessViewController: GAITrackedViewController {

    let statusLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.lineBreakMode = .byWordWrapping
        l.font = UIFont.boldSystemFont(ofSize: 16)
        l.backgroundColor = .clear
        return l
    }()
    
    let webView: UIWebView = {
        let wv = UIWebView(frame: .zero)
        wv.allowsInlineMediaPlayback = true
        wv.mediaPlaybackRequiresUserAction = true
        wv.mediaPlaybackAllowsAirPlay = true
        wv.keyboardDisplayRequiresUserAction = true
        wv.scrollView.isScrollEnabled = false
        return wv
    }()
    
    var date : GSRDate?
    var location : GSRLocation?
    var ids : [Int]?
    var email : String?
    var password : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        registerForNotifications()
        
        DispatchQueue.main.async(execute: {
            let activityInd = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            activityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityInd)
            
            activityInd.startAnimating()
        })
        
        if let location = location {
            self.screenName = location.name
            GoogleAnalyticsManager.trackEvent(category: GoogleAnalyticsManager.events.category.studyRoomBooking, action: GoogleAnalyticsManager.events.action.attemptReservation, label: location.name, value: 1)
        }
        
        let networkingManager = GSRNetworkManager(email: email!, password: password!, gid: (location?.code)!, ids: ids!)
        
        networkingManager.bookSelection()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(statusLabel)
        view.addSubview(webView)
        
        _ = statusLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 100, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 100)
        
        _ = webView.anchor(statusLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessViewController.handleNotification(_:)), name:NSNotification.Name(rawValue: "ProgressMessageNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessViewController.handleStatusMessage(_:)), name:NSNotification.Name(rawValue: "StatusMessageNotification"), object: nil)
    }
    
    func handleStatusMessage(_ notification: Notification) {
        let html = notification.object as! String
        self.webView.loadHTMLString(html, baseURL: nil)
        DispatchQueue.main.async(execute: {
            let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProcessViewController.dismissSelf))
            self.navigationItem.rightBarButtonItem = button
        })
        
    }
    
    func handleNotification(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            let msg = notification.object as! String
            self.statusLabel.text = msg
            self.trackMessage(msg)
        })
    }
    
    func dismissSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    internal func updateLabel(_ msg: String) {
        statusLabel.text = msg
    }
    
    internal func trackMessage(_ msg: String) {
        let category = GoogleAnalyticsManager.events.category.studyRoomBooking
        let action = GoogleAnalyticsManager.events.action.attemptReservation
        if msg.contains("Failed") || msg.contains("Error") {
            GoogleAnalyticsManager.trackEvent(category: category, action: action, label: "Failed", value: -1)
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "email")
            defaults.removeObject(forKey: "password")
        }
    }
}
