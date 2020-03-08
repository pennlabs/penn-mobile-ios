//
//  PacCodeViewController.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/3/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class PacCodeViewController : UIViewController, ShowsAlert, IndicatorEnabled {
    
    var pacCode : String?
        
    lazy var quadDigitLabel = [digitLabel, digitLabel, digitLabel, digitLabel]
    
    let pacCodeHStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.title = "PAC Code"
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        
        setupPacCodeHStack()
        setupPacCodeInfoLabel()
    }
    
    var digitLabel : UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 70).isActive = true
        label.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        
        label.backgroundColor = .grey6
        
        return label
    }

    func setupPacCodeHStack() {
        pacCodeHStack.axis = .horizontal
        pacCodeHStack.distribution = .equalCentering
        pacCodeHStack.spacing = 10.0
        
        for digitLabel in quadDigitLabel {
            pacCodeHStack.addArrangedSubview(digitLabel)
        }
        
        view.addSubview(pacCodeHStack)
        pacCodeHStack.translatesAutoresizingMaskIntoConstraints = false
        pacCodeHStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        pacCodeHStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func setupPacCodeInfoLabel() {
        let pacCodeInfoLabel = UILabel()
        pacCodeInfoLabel.textColor = .labelPrimary
        pacCodeInfoLabel.font = UIFont.systemFont(ofSize: 35)
        pacCodeInfoLabel.text = "Your PAC Code is"
        
        view.addSubview(pacCodeInfoLabel)
        pacCodeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        pacCodeInfoLabel.bottomAnchor.constraint(equalTo: pacCodeHStack.topAnchor, constant: -30).isActive = true
        pacCodeInfoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func updatePACCode() {
        if let pacCode = pacCode {
            var counter = 0
            for pacCodeDigit in pacCode {
                quadDigitLabel[counter].text = "\(pacCodeDigit)"
                counter += 1
            }
        } else {
            for box in quadDigitLabel {
                box.text = ""
            }
        }
    }
}

// MARK: - Local Authentication
extension PacCodeViewController : KeychainAccessible, LocallyAuthenticatable {
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestAuthentication(cancelText: "Go Back", reasonText: "Authenticate to see your PAC Code")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pacCode = nil
        updatePACCode()
    }
    
    func handleAuthenticationSuccess() {
        if let pacCode = getPacCode() {
            self.pacCode = pacCode
        } else {
            if Account.isLoggedIn {
                self.showActivity()
                
                // Handle the case in which the user is logged in but hasn't yet fetched their PAC Codes
                // Acts as though the user pressed the refresh button
                PacCodeNetworkManager.instance.getPacCode { result in self.handleNetworkPacCodeRefreshCompletion(result) }
            } else {
                self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
            }
        }
        
        updatePACCode()
    }
    
    func handleAuthenticationFailure() {
        self.navigationController?.popViewController(animated: true)
    }
        
}

// MARK: - PAC Code Refreshing
extension PacCodeViewController {
    @objc func refreshButtonTapped() {
        let message = "Has there been a change to your PAC Code? Would you like Penn Mobile to update your information?"
        let alert = UIAlertController(title: "Update PAC Code", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let refreshPacCode = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.showActivity()
            PacCodeNetworkManager.instance.getPacCode { result in self.handleNetworkPacCodeRefreshCompletion(result) }
        })
        
        alert.addAction(refreshPacCode)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleNetworkPacCodeRefreshCompletion(_ result: Result<String, NetworkingError>) {
        DispatchQueue.main.async {
            self.hideActivity()
            
            switch result {
            case .success(let pacCode):
                self.savePacCode(pacCode)
                self.pacCode = pacCode
                self.showAlert(withMsg: "Your PAC Code has been updated.", title: "Success!", completion: self.updatePACCode)
                
            case .failure(.noInternet):
                self.showAlert(withMsg: "You appear to be offline.\nPlease try again later.", title: "Network Error", completion: { self.navigationController?.popViewController(animated: true) })
                
            case .failure(.parsingError):
                self.showAlert(withMsg: "Penn's PAC Code servers are currently not updating.We hope this will be fixed shortly", title: "Uh oh!", completion: { self.navigationController?.popViewController(animated: true) })
                
            case .failure(.authenticationError):
                self.showAlert(withMsg: "Unable to access your PAC Code.\nPlease login again.", title: "Login Error", completion: { self.handleAuthenticationError() })
                
            default:
                self.showAlert(withMsg: "Something went wrong.\nPlease try again later.", title: "Uh oh!", completion: { self.navigationController?.popViewController(animated: true) } )
            }
        }
    }
    
    fileprivate func handleAuthenticationError() {
        
        let llc = LabsLoginController { (success) in
            DispatchQueue.main.async {
                print("success")
                self.loginCompletion(success)
            }
        }
        
        let nvc = UINavigationController(rootViewController: llc)
        
        present(nvc, animated: true, completion: nil)
    }
    
    fileprivate func loginCompletion(_ successful: Bool) {
        if successful {
            self.showActivity()
            PacCodeNetworkManager.instance.getPacCode { result in self.handleNetworkPacCodeRefreshCompletion(result) }
        } else {
            showAlert(withMsg: "Something went wrong. Please try again later.", title: "Uh oh!", completion: { self.navigationController?.popViewController(animated: true) } )
        }
    }

}
