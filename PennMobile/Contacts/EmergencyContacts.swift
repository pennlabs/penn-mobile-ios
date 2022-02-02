//
//  EmergencyContacts.swift
//  PennMobile
//
//  Created by Josh Doman on 5/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Contacts

@objc class ContactManager: NSObject {
    
    static let shared = ContactManager()
    
    private var contacts = [CNMutableContact]()
    
    func addContacts(contacts: [SupportItem]) {
        for contact in contacts {
            let cnContact = CNMutableContact()
            cnContact.givenName = contact.name
            cnContact.phoneNumbers = [CNLabeledValue(
                label: CNLabelPhoneNumberiPhone,
                value: CNPhoneNumber(stringValue: "(408) 555-0126"))]
        }
    }
}
