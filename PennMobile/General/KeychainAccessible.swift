//
//  KeychainAccessible.swift
//  PennMobile
//
//  Created by Josh Doman on 1/1/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

protocol KeychainAccessible {}

extension KeychainAccessible {
    private var pennkeyKeychainKey: String {
        "PennKey"
    }

    private var passwordKeychainKey: String {
        "PennKey Password"
    }

    private var pacCodeKeychainKey: String {
        "PAC Code"
    }

    func getPennKey() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: pennkeyKeychainKey)
        } catch {
            return nil
        }
    }

    func getPassword() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: passwordKeychainKey)
        } catch {
            return nil
        }
    }

    func getPacCode() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: pacCodeKeychainKey)
        } catch {
            return nil
        }
    }

    func savePennKey(_ pennkey: String) {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.setValue(pennkey, for: pennkeyKeychainKey)
    }

    func savePassword(_ password: String) {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.setValue(password, for: passwordKeychainKey)
    }

    func savePacCode(_ pacCode: String) {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.setValue(pacCode, for: pacCodeKeychainKey)
    }

    func removePacCode() {
        let secureStore = getWebLoginSecureStore()
        try? secureStore.removeValue(for: pacCodeKeychainKey)
    }

    private func getWebLoginSecureStore() -> SecureStore {
        let genericPwdQueryable = GenericPasswordQueryable(service: "PennWebLogin")
        let secureStore = SecureStore(secureStoreQueryable: genericPwdQueryable)
        return secureStore
    }
}
