//
//  PacCodeViewController.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/3/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class PacCodeViewController : UIViewController, ShowsAlertForError, IndicatorEnabled {
    
    var pacCode : String?
        
    var digitLabel : UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 70).isActive = true
        label.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        
        label.backgroundColor = .grey6
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        
        return label
    }
    
    lazy var quadDigitLabel = [digitLabel, digitLabel, digitLabel, digitLabel]
    
    var pacCodeIcon: UIImageView!
    let pacCodeTitleLabel = UILabel()
    let pacCodeSecurityInfoLabel = UILabel()
    let pacCodeHStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .uiBackground
        
        self.title = "PAC Code"
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        
        setupPacCodeIcon()
        setupPacCodeTitleLabel()
        setupPacCodeSecurityInfoLabel()
        setupPacCodeHStack()
    }
    
    func setupPacCodeIcon() {
        pacCodeIcon = UIImageView(image: UIImage(named: "PAC_Code")!)
        pacCodeIcon.contentMode = .scaleAspectFill
        pacCodeIcon.tintColor = .labelPrimary
        
        view.addSubview(pacCodeIcon)
        pacCodeIcon.translatesAutoresizingMaskIntoConstraints = false
        pacCodeIcon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        pacCodeIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52).isActive = true
        pacCodeIcon.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func setupPacCodeTitleLabel() {
        pacCodeTitleLabel.textColor = .labelPrimary
        pacCodeTitleLabel.font = UIFont.systemFont(ofSize: 35)
        pacCodeTitleLabel.text = "PAC Code"
        
        view.addSubview(pacCodeTitleLabel)
        pacCodeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pacCodeTitleLabel.topAnchor.constraint(equalTo: pacCodeIcon.bottomAnchor, constant: 10).isActive = true
        pacCodeTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func setupPacCodeSecurityInfoLabel() {
        pacCodeSecurityInfoLabel.textColor = .labelSecondary
        pacCodeSecurityInfoLabel.font = UIFont.systemFont(ofSize: 16)
        pacCodeSecurityInfoLabel.text = "After being fetched from Campus Express, your PAC code is stored in your device’s Secure Enclave.\n\nIt requires your authentication to view each time and never leaves your device."
        
        pacCodeSecurityInfoLabel.numberOfLines = 0
        pacCodeSecurityInfoLabel.textAlignment = .center
        
        
        view.addSubview(pacCodeSecurityInfoLabel)
        pacCodeSecurityInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        pacCodeSecurityInfoLabel.topAnchor.constraint(equalTo: pacCodeTitleLabel.bottomAnchor, constant: 20).isActive = true
        pacCodeSecurityInfoLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.80).isActive = true
        pacCodeSecurityInfoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
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
        pacCodeHStack.topAnchor.constraint(equalTo: pacCodeSecurityInfoLabel.bottomAnchor, constant: 25).isActive = true
        pacCodeHStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    func updatePACCode() {
        if let pacCode = pacCode {
            let pacCodefadeInAnimation: CATransition = CATransition()
            pacCodefadeInAnimation.duration = 0.5
            pacCodefadeInAnimation.type = CATransitionType.fade
            pacCodefadeInAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            
            var counter = 0
            for pacCodeDigit in pacCode {
                quadDigitLabel[counter].layer.add(pacCodefadeInAnimation, forKey: "changeTextTransition")
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
            updatePACCode()
        } else {
            if Account.isLoggedIn {
                // Handle the case in which the user is logged in but hasn't yet fetched their PAC Codes
                handleNetworkPacCodeRefetch()
            } else {
                self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
            }
        }
    }
    
    func handleAuthenticationFailure() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - PAC Code Refreshing
extension PacCodeViewController {
    @objc func refreshButtonTapped() {
        let message = "Has there been a change to your PAC Code? Would you like Penn Mobile to refresh your information?"
        let alert = UIAlertController(title: "Refresh PAC Code", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let refreshPacCode = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.handleNetworkPacCodeRefetch()
        })
        
        alert.addAction(refreshPacCode)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleNetworkPacCodeRefetch() {
        self.showActivity()
        PacCodeNetworkManager.instance.getPacCode { result in
            DispatchQueue.main.async {
                self.handleNetworkPacCodeResult(result)
                self.hideActivity()
            }
        }
    }
    
    fileprivate func handleNetworkPacCodeResult(_ result: Result<String, NetworkingError>) {
        
        let popVC : () -> Void = { self.navigationController?.popViewController(animated: true) }
        
        showRefreshAlertForError(result: result, title: "PAC Code", success: self.handleNetworkPacCodeRefreshCompletion(_:), noInternet: popVC, parsingError: popVC, authenticationError: self.handleAuthenticationError)
    }
    
    fileprivate func handleNetworkPacCodeRefreshCompletion(_ pacCode: String) {
        self.savePacCode(pacCode)
        self.pacCode = pacCode
    }
    
    fileprivate func handleAuthenticationError() {
        let llc = LabsLoginController { (success) in
            DispatchQueue.main.async {
                self.loginCompletion(success)
            }
        }
        
        llc.handleCancel = { self.navigationController?.popViewController(animated: true) }
        
        let nvc = UINavigationController(rootViewController: llc)
        
        present(nvc, animated: true, completion: nil)
    }
    
    fileprivate func loginCompletion(_ successful: Bool) {
        if successful {
            handleNetworkPacCodeRefetch()
        } else {
            showAlert(withMsg: "Something went wrong. Please try again later.", title: "Uh oh!", completion: { self.navigationController?.popViewController(animated: true) } )
        }
    }

}
