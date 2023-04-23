//
//  KeychainAccessibleExtensions.swift
//  PennMobile
//
//  Created by Anthony Li on 11/5/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

extension KeychainAccessible {

    func savePennKey(_ pennkey: String) {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.setValue(pennkey, for: pennkeyKeychainKey)
    }

    func removePennKey() {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.removeValue(for: pennkeyKeychainKey)
    }

    func savePassword(_ password: String) {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.setValue(password, for: passwordKeychainKey)
    }

    func removePassword() {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.removeValue(for: passwordKeychainKey)
    }

    func savePacCode(_ pacCode: String) {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.setValue(pacCode, for: pacCodeKeychainKey)
    }

    func removePacCode() {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.removeValue(for: pacCodeKeychainKey)
    }

    func saveDiningToken(_ diningToken: String) {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.setValue(diningToken, for: diningTokenKeychainKey)
    }

    func removeDiningToken() {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.removeValue(for: diningTokenKeychainKey)
        UserDefaults.standard.clearDiningBalance()
    }

}
