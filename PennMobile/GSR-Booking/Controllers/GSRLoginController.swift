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
    fileprivate var emailField: UITextField!
    
    fileprivate var messageView: UITextView!

    fileprivate let edgeOffset: CGFloat = 24
    fileprivate let spaceBetween: CGFloat = 20
    
    var booking: GSRBooking!
    
    var shouldShowCancel: Bool = true
    var shouldShowSuccessMessage: Bool = false
    
    var message: String? // "Built by Eric Wang '21 and Josh Doman '20. Special thanks to Yagil Burowski '17 for donating the original design of this feature to Penn Labs."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = booking == nil ? "Contact Info" : "Reserve"
        
        if booking == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCredentials(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(saveCredentials(_:)))
        }
        if shouldShowCancel {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        }
        
        self.prepareUI()
        
        if let user = GSRUser.getUser() {
            self.firstNameField.text = user.firstName
            self.lastNameField.text = user.lastName
            self.emailField.text = user.email
            self.firstNameField.becomeFirstResponder()
        } else if let student = Student.getStudent() {
            self.firstNameField.text = student.first
            self.lastNameField.text = student.last
            self.emailField.text = student.email
            if self.firstNameField.text != nil && self.emailField.text == nil {
                self.emailField.becomeFirstResponder()
            } else {
                self.firstNameField.becomeFirstResponder()
            }
        } else {
            self.firstNameField.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailField.resignFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return firstNameField.resignFirstResponder() ||
        lastNameField.resignFirstResponder() ||
        emailField.resignFirstResponder() // ||
        // phoneNumberField.resignFirstResponder()
    }
}

// MARK: - Setup UI
extension GSRLoginController {
    fileprivate func prepareUI() {
        prepareFirstNameField()
        prepareLastNameField()
        prepareEmailField()
        prepareMessage()
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
        firstNameField.delegate = self
        firstNameField.tag = 0
        
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
        lastNameField.delegate = self
        lastNameField.tag = 1
        
        view.addSubview(lastNameField)
        _ = lastNameField.anchor(firstNameField.topAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: edgeOffset/2, bottomConstant: 0, rightConstant: edgeOffset, widthConstant: 0, heightConstant: 44)
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
        emailField.delegate = self
        emailField.returnKeyType = .done
        emailField.tag = 2
        
        view.addSubview(emailField)
        let topAnchor = firstNameField.bottomAnchor
        _ = emailField.anchor(topAnchor, left: firstNameField.leftAnchor, bottom: nil, right: lastNameField.rightAnchor, topConstant: spaceBetween, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
    }
    
    private func prepareMessage() {
        guard let message = message else { return }
        let messageView = UITextView()
        messageView.text = message
        messageView.textColor = UIColor.lightGray
        messageView.isScrollEnabled = false
        messageView.isEditable = false
        messageView.isSelectable = false
        messageView.font = UIFont.systemFont(ofSize: 14)
        
        view.addSubview(messageView)
        _ = messageView.anchor(emailField.bottomAnchor, left: emailField.leftAnchor, bottom: nil, right: emailField.rightAnchor, topConstant: spaceBetween, leftConstant: -4, bottomConstant: 0, rightConstant: -4, widthConstant: 0, heightConstant: 0)
    }
}

// MARK: - TextFieldDelegate
extension GSRLoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            saveCredentials(textField)
        }
        return false
    }
}

// MARK: - Handlers
extension GSRLoginController: GSRBookable {
    @objc fileprivate func saveCredentials(_ sender: Any) {
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text else {
            return
        }
        
        if firstName == "" || lastName == "" || email == "" {
            showAlert(withMsg: "A field was left blank. Please fill it out before submitting.", completion: nil)
            return // A field is left blank
        } else if !email.contains("upenn.edu") || !email.contains("@") {
            showAlert(withMsg: "The email field is malformed. Please make sure to use your Penn email.", completion: nil)
            return // Malformed email, please use email ending in upenn.edu
        }
        
        _ = resignFirstResponder()

        let user = GSRUser(firstName: firstName, lastName: lastName, email: email, phone: "2158986533")
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
            
            if shouldShowSuccessMessage {
                showAlert(withMsg: "Your information has been saved.", title: "Success!", completion: nil)
            }
        }
    }
    
    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
