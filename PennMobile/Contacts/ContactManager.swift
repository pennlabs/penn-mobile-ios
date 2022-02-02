//
//  EmergencyContacts.swift
//  PennMobile
//
//  Created by Josh Doman on 5/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Contacts

extension SupportItem {
    
    var cnContact: CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = self.contactName
        contact.phoneNumbers = [CNLabeledValue(
            label: CNLabelPhoneNumberiPhone,
            value: CNPhoneNumber(stringValue: self.phoneFiltered))]
        if let desc = self.descriptionText {
            contact.note = desc
        }
        return contact
    }
    
}

class ContactManager: NSObject {
    
    static let shared = ContactManager()
    
    func save(_ items: [SupportItem], callback: @escaping (_ success: Bool) -> Void) {
        let saveRequest = CNSaveRequest()
        let store = CNContactStore()
        for item in items {
            saveRequest.add(item.cnContact, toContainerWithIdentifier: nil)
        }
        do {
            try store.execute(saveRequest)
            callback(true)
        } catch {
            callback(false)
        }
    }
    
    func delete(_ items: [SupportItem], callback: (_ success: Bool) -> Void) {
        var successful = true
        for item in items {
            delete(item) { (success) in
                successful = successful ? success : false
            }
        }
        callback(successful)
    }
    
    func delete(_ item: SupportItem, callback2: (_ success: Bool) -> Void) {
        let store = CNContactStore()
        let predicate = CNContact.predicateForContacts(matchingName: item.contactName)
        let toFetch = [CNContactGivenNameKey] as [CNKeyDescriptor]
        
        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch)
            guard contacts.count > 0 else {
                callback2(true) // no contacts found
                return
            }
            
            for contact in contacts {
                let req = CNSaveRequest()
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                req.delete(mutableContact)
                
                do {
                    try store.execute(req)
                    callback2(true) // successfully deleted user
                } catch {
                    callback2(false)
                }
            }
        } catch {
            callback2(false)
        }
    }
}
