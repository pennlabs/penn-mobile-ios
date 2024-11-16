//
//  ContactsView.swift
//  PennMobile
//
//  Created by Jordan Hochman on 11/16/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct ContactsView: View {
    @State var contactsExist = false
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Divider()

                ForEach(Contact.contacts) { contact in
                    ContactRowView(contact: contact)
                    
                    Divider()
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let success = contactsExist ?  ContactManager.shared.deleteContacts(Contact.contacts) : ContactManager.shared.saveContacts(Contact.contacts)
                    if success {
                        contactsExist = ContactManager.shared.checkContactsExist(Contact.contacts)
                    }
                    let didAddContacts = contactsExist
                    
                    alertTitle = success ? (didAddContacts ? "Saved" : "Removed"): "Uh oh!"
                    alertMessage = success ? "All Penn contacts have been \(didAddContacts ? "saved to" : "removed from") your address book." : "Please try again. You must permit access to your contact book."
                    showSettings = !success
                    showAlert = true
                }) {
                    Text(contactsExist ? "Remove contacts" : "Add contacts")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            showSettings ?
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Settings"), action: openSettings),
                    secondaryButton: .cancel()
                ) :
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Ok"))
                )
        }
        .onAppear {
             contactsExist = ContactManager.shared.checkContactsExist(Contact.contacts)
        }
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    NavigationStack {
        ContactsView()
    }
}
