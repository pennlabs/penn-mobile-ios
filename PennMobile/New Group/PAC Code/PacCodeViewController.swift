//
//  PacCodeViewController.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/3/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class PacCodeViewController : UIViewController, KeychainAccessible, ShowsAlert, IndicatorEnabled {
    
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
    
    func refreshPacCode() {
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
extension PacCodeViewController : LocalAuthentication {
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleAuthentication(cancelText: "Go Back", reasonText: "Authenticate to see your PAC Code")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pacCode = nil
        refreshPacCode()
    }
    
    func handleAuthenticationSuccess() {
        if let pacCode = getPacCode() {
            self.pacCode = pacCode
        } else {
            PacCodeNetworkManager.instance.getPacCode(callback: savePacCode(_:))

            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
        }
        
        refreshPacCode()
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
            PacCodeNetworkManager.instance.getPacCode(callback: self.handleNetworkPacCodeRefreshCompletion(_:))
        })
        
        alert.addAction(refreshPacCode)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleNetworkPacCodeRefreshCompletion(_ pacCode: String?) {
        DispatchQueue.main.async {
            self.hideActivity()
            if let pacCode = pacCode {
                self.savePacCode(pacCode)
                self.pacCode = pacCode
                self.showAlert(withMsg: "Your PAC Code has been updated.", title: "Success!", completion: self.refreshPacCode)
            } else {
                self.showAlert(withMsg: "Unable to access your courses. Please try again later.", title: "Uh oh!", completion: nil)
            }
        }
    }
//    fileprivate func fetch
    
}
