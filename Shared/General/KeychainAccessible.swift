//
//  KeychainAccessible.swift
//  PennMobile
//
//  Created by Josh Doman on 1/1/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class KeychainAccessible {

    static let instance = KeychainAccessible()

    var pennkeyKeychainKey: String {
        "PennKey"
    }

    var passwordKeychainKey: String {
        "PennKey Password"
    }

    var pacCodeKeychainKey: String {
        "PAC Code"
    }

    var diningTokenKeychainKey: String {
        "Dining Token"
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

    func getWebLoginSecureStore() -> SecureStore {
        let genericPwdQueryable = GenericPasswordQueryable(service: "PennWebLogin")
        let secureStore = SecureStore(secureStoreQueryable: genericPwdQueryable)
        return secureStore
    }

    func getDiningToken() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: diningTokenKeychainKey)
        } catch {
            return nil
        }
    }

}
