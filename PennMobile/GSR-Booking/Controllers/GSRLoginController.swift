//
//  GSRLoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class GSRLoginController: UIViewController, IndicatorEnabled, ShowsAlert {
    
    fileprivate var firstNameField: UITextField!
    fileprivate var lastNameField: UITextField!
    fileprivate var groupNameField: UITextField!
    fileprivate var emailField: UITextField!
    fileprivate var phoneNumberField: UITextField!

    fileprivate let edgeOffset: CGFloat = 24
    fileprivate let spaceBetween: CGFloat = 20
    
    var booking: GSRBooking!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = booking == nil ? "Contact Info" : "Reserve"
        
        if booking == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCredentials(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(saveCredentials(_:)))
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        
        prepareUI()
        firstNameField.becomeFirstResponder()
        
        guard let user = GSRUser.getUser() else { return }
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        emailField.text = user.email
        phoneNumberField.text = user.phone
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailField.resignFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return firstNameField.resignFirstResponder() ||
        lastNameField.resignFirstResponder() ||
        emailField.resignFirstResponder() ||
        phoneNumberField.resignFirstResponder()
    }
}

// MARK: - Setup UI
extension GSRLoginController {
    fileprivate func prepareUI() {
        prepareFirstNameField()
        prepareLastNameField()
        // prepareGroupNameField()
        prepareEmailField()
        preparePhoneNumberField()
    }
    
    private func prepareFirstNameField() {
        firstNameField = UITextField()
        firstNameField.placeholder = "First"
        firstNameField.font = UIFont.systemFont(ofSize: 14)
        firstNameField.keyboardType = .alphabet
        firstNameField.textAlignment = .natural
        firstNameField.borderStyle = .roundedRect
        firstNameField.autocorrectionType = .no
        firstNameField.spellCheckingType = .no
        firstNameField.autocapitalizationType = .words
        
        view.addSubview(firstNameField)
        _ = firstNameField.anchor(nil, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 0, leftConstant: edgeOffset, bottomConstant: 0, rightConstant: edgeOffset/2, widthConstant: 0, heightConstant: 44)
        
        if #available(iOS 11.0, *) {
            firstNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        } else {
            firstNameField.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 50).isActive = true
        }
    }
    
    private func prepareLastNameField() {
        lastNameField = UITextField()
        lastNameField.placeholder = "Last"
        lastNameField.font = UIFont.systemFont(ofSize: 14)
        lastNameField.keyboardType = .alphabet
        lastNameField.textAlignment = .natural
        lastNameField.borderStyle = .roundedRect
        lastNameField.autocorrectionType = .no
        lastNameField.spellCheckingType = .no
        lastNameField.autocapitalizationType = .words
        
        view.addSubview(lastNameField)
        _ = lastNameField.anchor(firstNameField.topAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: edgeOffset/2, bottomConstant: 0, rightConstant: edgeOffset, widthConstant: 0, heightConstant: 44)
    }
    
    private func prepareGroupNameField() {
        if booking == nil {
            return
        }
        
        groupNameField = UITextField()
        groupNameField.placeholder = "Group name"
        groupNameField.font = UIFont.systemFont(ofSize: 14)
        groupNameField.keyboardType = .alphabet
        groupNameField.textAlignment = .natural
        groupNameField.borderStyle = .roundedRect
        groupNameField.autocorrectionType = .no
        groupNameField.spellCheckingType = .no
        groupNameField.autocapitalizationType = .words
        
        view.addSubview(groupNameField)
        _ = groupNameField.anchor(firstNameField.bottomAnchor, left: firstNameField.leftAnchor, bottom: nil, right: lastNameField.rightAnchor, topConstant: spaceBetween, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
    }
    
    private func prepareEmailField() {
        emailField = UITextField()
        emailField.placeholder = "Penn email (e.g. amyg@sas.upenn.edu)"
        emailField.font = UIFont.systemFont(ofSize: 14)
        emailField.keyboardType = .emailAddress
        emailField.textAlignment = .natural
        emailField.borderStyle = .roundedRect
        emailField.autocorrectionType = .no
        emailField.spellCheckingType = .no
        emailField.autocapitalizationType = .none
        
        view.addSubview(emailField)
        let topAnchor = groupNameField == nil ? firstNameField.bottomAnchor : groupNameField.bottomAnchor
        _ = emailField.anchor(topAnchor, left: firstNameField.leftAnchor, bottom: nil, right: lastNameField.rightAnchor, topConstant: spaceBetween, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
    }
    
    private func preparePhoneNumberField() {
        phoneNumberField = UITextField()
        phoneNumberField.placeholder = "Phone number (e.g. 2158985000)"
        phoneNumberField.font = UIFont.systemFont(ofSize: 14)
        phoneNumberField.keyboardType = .phonePad
        phoneNumberField.textAlignment = .natural
        phoneNumberField.borderStyle = .roundedRect
        phoneNumberField.autocorrectionType = .no
        phoneNumberField.spellCheckingType = .no
        
        view.addSubview(phoneNumberField)
        _ = phoneNumberField.anchor(emailField.bottomAnchor, left: emailField.leftAnchor, bottom: nil, right: emailField.rightAnchor, topConstant: spaceBetween, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
    }
}

// MARK: - Handlers
extension GSRLoginController: GSRBookable {
    @objc fileprivate func saveCredentials(_ sender: Any) {
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let phone = phoneNumberField.text else {
            return
        }
        
        if firstName == "" || lastName == "" || email == "" || phone == "" {
            showAlert(withMsg: "A field was left blank. Please fill it out before submitting.", completion: nil)
            return // A field is left blank
        } else if !email.contains("upenn.edu") || !email.contains("@") {
            showAlert(withMsg: "The email field was malformed. Please make sure to use your Penn email.", completion: nil)
            return // Malformed email, please use email ending in upenn.edu
        }
        
        _ = resignFirstResponder()

        let user = GSRUser(firstName: firstName, lastName: lastName, email: email, phone: phone)
        if booking != nil {
            booking.user = user
            submitBooking(for: booking) { (success) in
                if success {
                    GSRUser.save(user: user)
                }
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            GSRUser.save(user: user)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
