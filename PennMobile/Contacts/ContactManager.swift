//
//  ContactManager.swift
//  PennMobile
//
//  Created by Jordan Hochman on 11/16/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Contacts

extension Contact {
    var cnContact: CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = self.contactName
        contact.phoneNumbers = [CNLabeledValue(
            label: CNLabelPhoneNumberMain,
            value: CNPhoneNumber(stringValue: self.phoneFiltered))]
        if let desc = self.description {
            contact.note = desc
        }
        return contact
    }
}

class ContactManager: NSObject {
    static let shared = ContactManager()
    private let contactStore = CNContactStore()
    
    func requestAccess() async -> Bool {
        return await withCheckedContinuation { continuation in
            contactStore.requestAccess(for: .contacts) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func doesHaveAccess() -> Bool {
        let access = CNContactStore.authorizationStatus(for: .contacts)
        
        var valid: [CNAuthorizationStatus] = [.authorized]
        if #available(iOS 18.0, *) {
            valid.append(.limited)
        }
        return valid.contains(access)
    }

    func saveContacts(_ contacts: [Contact]) -> Bool {
        let saveRequest = CNSaveRequest()
        for contact in contacts {
            saveRequest.add(contact.cnContact, toContainerWithIdentifier: nil)
        }

        do {
            try contactStore.execute(saveRequest)
            return true
        } catch {
            return false
        }
    }

    func deleteContacts(_ contacts: [Contact]) -> Bool {
        var success = true
        for contact in contacts {
            if !deleteContact(contact) {
                success = false
            }
        }
        return success
    }

    func deleteContact(_ contact: Contact) -> Bool {
        let predicate = CNContact.predicateForContacts(matchingName: contact.contactName)
        let toFetch = [CNContactGivenNameKey] as [CNKeyDescriptor]

        do {
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: toFetch)
            guard !contacts.isEmpty else {
                return true // no contacts found
            }

            var success = true
            for contact in contacts {
                let req = CNSaveRequest()
                let mutableContact = contact.mutableCopy() as? CNMutableContact
                if let mutableContact {
                    req.delete(mutableContact)
                }
                
                do {
                    try contactStore.execute(req)
                } catch {
                    success = false
                }
            }
            return success
        } catch {
            return false
        }
    }
    
    func checkContactsExist(_ contacts: [Contact]) -> Bool {
        if !doesHaveAccess() {
            return false
        }
        
        let toFetch = [CNContactGivenNameKey] as [CNKeyDescriptor]
        
        for contact in contacts {
            let predicate = CNContact.predicateForContacts(matchingName: contact.contactName)

            do {
                let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: toFetch)
                if contacts.isEmpty {
                    return false // at least one contact does not exist
                }
            } catch {
                return false // error occured during fetching
            }
        }
        return true
    }
}
