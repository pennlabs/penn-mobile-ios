//
//  EmergencyController.swift
//  PennMobile
//
//  Created by Josh Doman on 5/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class EmergencyController: SupportTableViewController, ShowsAlert {
    
    let contacts: [SupportItem] = SupportItem.getContacts() as! [SupportItem]
    
    internal var contactsButtonTitle: String {
        get {
            return UserDefaults.standard.bool(forKey: "Contacts added") ? "Remove all" : "Add all"
        }
    }
    
    private lazy var addRemoveButton: UIBarButtonItem = {
        return UIBarButtonItem(title: self.contactsButtonTitle, style: .done, target: self, action: #selector(addRemove(_:)))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = addRemoveButton
    }
    
    internal func addRemove(_ sender: UIBarButtonItem) {
        if UserDefaults.standard.bool(forKey: "Contacts added") {
            removeContacts()
        } else {
            addContacts()
        }
    }
    
    internal func updateAddRemoveButton() {
        self.addRemoveButton.tintColor = .clear
        addRemoveButton.title = contactsButtonTitle
        self.addRemoveButton.tintColor = nil
    }
}

extension EmergencyController {
    internal func addContacts() {
        ContactManager.shared.save(contacts) { (success) in
            contactManagerFinished(success, isAddingContacts: true)
        }
    }
    
    internal func removeContacts() {
        ContactManager.shared.delete(contacts) { (success) in
            self.contactManagerFinished(success, isAddingContacts: false)
        }
    }
    
    private func contactManagerFinished(_ success: Bool, isAddingContacts: Bool) {
        let msg = success ? "All Penn contacts have been \(isAddingContacts ? "saved" : "removed") to your address book." : "Please try again. You must permit access to your contact book."
        let title = success ? (isAddingContacts ? "Saved" : "Removed"): "Uh oh!"
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        if success {
            UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "Contacts added"), forKey: "Contacts added")
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                self.updateAddRemoveButton()
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
                self.updateAddRemoveButton()
            }))
            
            alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                        self.updateAddRemoveButton()
                    })
                }
            }))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
