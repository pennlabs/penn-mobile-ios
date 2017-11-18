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
            self.title = "In Progress"
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
        DispatchQueue.main.async {
            let html = notification.object as! String
            self.webView.loadHTMLString(html, baseURL: nil)
            let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProcessViewController.dismissSelf))
            self.navigationItem.rightBarButtonItem = button
            
            // Track Success/Failed event
            let status = notification.object as! String
            self.trackStatus(status)
        }
    }
    
    func handleNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            let msg = notification.object as! String
            self.statusLabel.text = msg
        }
    }
    
    func dismissSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    internal func updateLabel(_ msg: String) {
        statusLabel.text = msg
    }
    
    internal func trackStatus(_ status: String) {
        guard let title = statusLabel.text else { return }
        
        let category = GoogleAnalyticsManager.events.category.studyRoomBooking
        let action = GoogleAnalyticsManager.events.action.attemptReservation
        if title.contains("Failed") || title.contains("Error") {
            if status.contains("cannot book more than one room at the same time") {
                GoogleAnalyticsManager.shared.trackEvent(category: category, action: action, label: "Failed - already booked a room at that time", value: -1)
            } else {
                GoogleAnalyticsManager.shared.trackEvent(category: category, action: action, label: "Failed 2.0", value: -1)
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "email")
                defaults.removeObject(forKey: "password")
            }
        } else {
            GoogleAnalyticsManager.shared.trackEvent(category: category, action: action, label: "Success 2.0", value: 1)
        }
    }
}
