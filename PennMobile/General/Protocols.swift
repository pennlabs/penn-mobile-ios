//
//  Protocols.swift
//  PennMobile
//
//  Created by Josh Doman on 5/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import MBProgressHUD
import CoreLocation

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
    func trackScreen(_ name: String?) {
        if let name = name {
            FirebaseAnalyticsManager.shared.trackScreen(name)
            DatabaseManager.shared.trackVC(name)
        }
    }
}

protocol URLOpenable {}

extension URLOpenable {
    
    //Source: https://stackoverflow.com/questions/38964264/openurl-in-ios10
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                          completionHandler: {
                                            (success) in
                                            //print("Open \(scheme): \(success)")
                })
            } else {
                _ = UIApplication.shared.openURL(url)
                //let success = UIApplication.shared.openURL(url)
                //print("Open \(scheme): \(success)")
            }
        }
    }
}

protocol HairlineRemovable {}

extension HairlineRemovable {
    
    func removeHairline(from view: UIView) {
        if let hairline = findHairlineImageViewUnder(view: view) {
            hairline.isHidden = true
        }
    }
    
    //finds hairline underview if there is one
    private func findHairlineImageViewUnder(view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            let imageView = findHairlineImageViewUnder(view: subview)
            if let iv = imageView {
                return iv
            }
        }
        return nil
    }
}

protocol ShowsAlert {
    func showAlert(withMsg: String, title: String, completion: (() -> Void)?)
}

extension ShowsAlert where Self: UIViewController {
    func showAlert(withMsg: String, title: String = "Error", completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: withMsg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            if let completion = completion {
                completion()
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

protocol LocationPermissionRequestable: CLLocationManagerDelegate {}

extension LocationPermissionRequestable {
    func hasLocationPermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }
}
