//
//  Protocols.swift
//  PennMobile
//
//  Created by Josh Doman on 5/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import CoreLocation
import LocalAuthentication
import PennMobileShared

protocol IndicatorEnabled {}

extension IndicatorEnabled where Self: UIViewController {
    func showActivity(isUserInteractionEnabled: Bool = false) {
        view.isUserInteractionEnabled = false

        if let activityIndicator = findActivity() {
            activityIndicator.startAnimating()
        } else {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.startAnimating()
            view.addSubview(activityIndicator)

            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            ])
        }
    }

    func hideActivity() {
        view.isUserInteractionEnabled = true
        findActivity()?.stopAnimating()
    }

    func findActivity() -> UIActivityIndicatorView? {
        return view.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }
}

extension IndicatorEnabled where Self: UIView {
    func showActivity(isUserInteractionEnabled: Bool = false) {
        self.isUserInteractionEnabled = false

        if let activityIndicator = findActivity() {
            activityIndicator.startAnimating()
        } else {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.startAnimating()
            self.addSubview(activityIndicator)

            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor)
            ])
        }
    }

    func hideActivity() {
        self.isUserInteractionEnabled = true
        findActivity()?.stopAnimating()
    }

    func findActivity() -> UIActivityIndicatorView? {
        return self.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }
}

protocol Trackable {}

extension Trackable where Self: UIViewController {
    func trackScreen(_ name: String?) {
        if let name = name {
            FirebaseAnalyticsManager.shared.trackScreen(name)
        }
    }
}

protocol URLOpenable {}

extension URLOpenable {

    // Source: https://stackoverflow.com/questions/38964264/openurl-in-ios10
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                      completionHandler: { (_) in
                // print("Open \(scheme): \(success)")
            })
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

    // finds hairline underview if there is one
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
    func showOption(withMsg: String, title: String, onAccept: (() -> Void)?, onCancel: (() -> Void)?)
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

    func showOption(withMsg: String, title: String = "Error", onAccept: (() -> Void)?, onCancel: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: withMsg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in
            if let completion = onCancel {
                completion()
            }
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let completion = onAccept {
                completion()
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

protocol ShowsAlertForError: ShowsAlert {
    func showRefreshAlertForError<T>(result: Result<T, NetworkingError>, title: String, success: @escaping (T) -> Void, noInternet: (() -> Void)?, parsingError: (() -> Void)?, serverError: (() -> Void)?, jsonError: (() -> Void)?, authenticationError: (() -> Void)?, other: (() -> Void)?)
}

extension ShowsAlertForError {
    func showRefreshAlertForError<T>(result: Result<T, NetworkingError>, title: String, success: @escaping (T) -> Void, noInternet: (() -> Void)? = nil, parsingError: (() -> Void)? = nil, serverError: (() -> Void)? = nil, jsonError: (() -> Void)? = nil, authenticationError: (() -> Void)? = nil, other: (() -> Void)? = nil) {
        switch result {
        case .success(let content):
            self.showAlert(withMsg: "Your \(title) has been refreshed.", title: "Refresh Complete!", completion: { success(content) })

        case .failure(.noInternet):
            self.showAlert(withMsg: "You appear to be offline.\nPlease try again later.", title: "Network Error", completion: noInternet)

        case .failure(.parsingError):
            self.showAlert(withMsg: "Something went wrong. Please try again later.", title: "Uh oh!", completion: parsingError)

        case .failure(.serverError):
            self.showAlert(withMsg: "Penn's \(title) servers are currently not updating. We hope this will be fixed shortly.", title: "Uh oh!", completion: serverError)

        case .failure(.jsonError):
            self.showAlert(withMsg: "Something went wrong. Please try again later.", title: "Uh oh!", completion: jsonError)

        case .failure(.authenticationError):
            self.showAlert(withMsg: "Unable to access your courses.\nPlease login again.", title: "Login Error", completion: authenticationError)

        case .failure(.other):
            self.showAlert(withMsg: "Unable to access your courses.\nPlease login again.", title: "Login Error", completion: authenticationError)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

protocol LocationPermissionRequestable: CLLocationManagerDelegate {}

extension LocationPermissionRequestable {
    func hasLocationPermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager().authorizationStatus {
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

protocol LocallyAuthenticatable {
    func handleAuthenticationSuccess()
    func handleAuthenticationFailure()
}

extension LocallyAuthenticatable {

    func requestAuthentication(cancelText: String, reasonText: String) {
        let context = LAContext()
        context.localizedCancelTitle = cancelText

        // Check if we have the needed hardware support.
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonText ) { success, _ in

                if success {
                    // Move to the main thread because the user may request UI changes.
                    DispatchQueue.main.async {
                        self.handleAuthenticationSuccess()
                    }

                } else {
                    // Failed to authenticate with FaceID/passcode
                    DispatchQueue.main.async {
                        self.handleAuthenticationFailure()
                    }
                }
            }
        } else {
            // Can't evaluate policy
            DispatchQueue.main.async {
                self.handleAuthenticationFailure()
            }
        }
    }
}
