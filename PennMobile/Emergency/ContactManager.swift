//
//  EmergencyContacts.swift
//  PennMobile
//
//  Created by Josh Doman on 5/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Contacts

class ContactManager: NSObject {
    
    static let shared = ContactManager()
    
    func save(_ items: [SupportItem], callback: (_ success: Bool) -> Void) {
        let saveRequest = CNSaveRequest()
        let store = CNContactStore()
        for item in items {
            let contact = createContact(for: item)
            saveRequest.add(contact, toContainerWithIdentifier:nil)
        }
        
        do {
            try store.execute(saveRequest)
            callback(true)
        } catch {
            callback(false) //fails to save contacts (probably didn't give permission)
        }
    }
    
    private func createContact(for item: SupportItem) -> CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = item.contactName
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue: item.phoneFiltered))]
        if let desc = item.descriptionText {
            contact.note = desc
        }
        return contact
    }
    
    func delete(_ items: [SupportItem], callback: (_ success: Bool) -> Void) {
        var successful = true
        for item in items {
            delete(for: item) { (success) in
                successful = successful ? success : false
            }
        }
        callback(successful)
    }
    
    private func delete(for item: SupportItem, callback: (_ success: Bool) -> Void) {
        let store = CNContactStore()
        let predicate = CNContact.predicateForContacts(matchingName: item.contactName)
        let toFetch = [CNContactGivenNameKey] as [CNKeyDescriptor]
        
        do{
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch)
            guard contacts.count > 0 else{
                callback(true) //no contacts found
                return
            }
            
            for contact in contacts {
                let req = CNSaveRequest()
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                req.delete(mutableContact)
                
                do {
                    try store.execute(req)
                    callback(true) //successfully deleted user
                } catch {
                    callback(false)
                }
            }
        } catch let err{
            callback(false)
        }
    }
}


