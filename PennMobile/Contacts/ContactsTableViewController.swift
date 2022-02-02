//
//  SupportTableViewController2.swift
//  PennMobile
//
//  Created by Josh Doman on 8/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol ContactCellDelegate: AnyObject {
    func call(number: String)
}

class ContactsTableViewController: GenericTableViewController, ShowsAlert {
    
    let contacts: [SupportItem] = SupportItem.getContacts() as! [SupportItem]
    
    fileprivate var expandedCellIndex: IndexPath?
    
    fileprivate var contactsButtonTitle: String {
        get {
            return UserDefaults.standard.bool(forKey: "Contacts added") ? "Remove all" : "Add all"
        }
    }
    
    fileprivate lazy var addRemoveButton: UIBarButtonItem = {
        return UIBarButtonItem(title: self.contactsButtonTitle, style: .done, target: self, action: #selector(addRemove(_:)))
    }()
    
    fileprivate let cellId = "supportCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = addRemoveButton
        self.title = "Contacts"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
    }
}

//Mark: TableView Datasource
extension ContactsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == expandedCellIndex {
            return 100.0
        }
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        cell.contact = contacts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var indexes = [indexPath]
        
        if let expandedIndex = expandedCellIndex, indexPath != expandedCellIndex {
            let expandedCell = tableView.cellForRow(at: expandedIndex) as! ContactCell
            expandedCell.isExpanded = false
            indexes.append(expandedIndex)
        }
        
        expandedCellIndex = indexPath == expandedCellIndex ? nil : indexPath
        
        let cell = tableView.cellForRow(at: indexPath) as! ContactCell
        cell.isExpanded = expandedCellIndex != nil
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func expandCell(cell: ContactCell, indexPath: IndexPath, expand: Bool) {
        cell.isExpanded = expand
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//Mark: add/remove UI button logic
extension ContactsTableViewController {
    @objc fileprivate func addRemove(_ sender: UIBarButtonItem) {
        if UserDefaults.standard.bool(forKey: "Contacts added") {
            removeContacts()
        } else {
            addContacts()
        }
    }
    
    fileprivate func updateAddRemoveButton() {
        self.addRemoveButton.tintColor = .clear
        addRemoveButton.title = contactsButtonTitle
        self.addRemoveButton.tintColor = nil
    }
}

//Mark: ContactManager logic
extension ContactsTableViewController {
    fileprivate func addContacts() {
        ContactManager.shared.save(contacts) { (success) in
            self.contactManagerFinished(success, isAddingContacts: true)
        }
    }
    
    fileprivate func removeContacts() {
        ContactManager.shared.delete(contacts) { (success) in
            self.contactManagerFinished(success, isAddingContacts: false)
        }
    }
    
    fileprivate func contactManagerFinished(_ success: Bool, isAddingContacts: Bool) {
        let msg = success ? "All Penn contacts have been \(isAddingContacts ? "saved to" : "removed from") your address book." : "Please try again. You must permit access to your contact book."
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
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (successful) in
                        if successful {
                            self.updateAddRemoveButton()
                        }
                    })
                }
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

//Mark: ContactCellDelegate
extension ContactsTableViewController: ContactCellDelegate {
    func call(number: String) {
        guard let number = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(number)
    }
}
