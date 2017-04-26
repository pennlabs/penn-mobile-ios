//
//  IndicatorEnabled.swift
//  PennMobile
//
//  Created by Josh Doman on 4/14/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import MBProgressHUD

protocol IndicatorEnabled {}

extension IndicatorEnabled where Self: UITableViewController {
    func showActivity() {
        tableView.isUserInteractionEnabled = false
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideActivity() {
        tableView.isUserInteractionEnabled = true
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}

extension IndicatorEnabled where Self: UIViewController {
    func showActivity() {
        view.isUserInteractionEnabled = false
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideActivity() {
        view.isUserInteractionEnabled = true
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}

extension IndicatorEnabled where Self: UIView {
    func showActivity() {
        self.isUserInteractionEnabled = false
        MBProgressHUD.showAdded(to: self, animated: true)
    }
    
    func hideActivity() {
        self.isUserInteractionEnabled = true
        MBProgressHUD.hide(for: self, animated: true)
    }
}

protocol Trackable {}

extension Trackable where Self: UIViewController {
    func track(_ name: String?) {
        if let name = name {
            GoogleAnalyticsManager.track(name)
        }
    }
}
