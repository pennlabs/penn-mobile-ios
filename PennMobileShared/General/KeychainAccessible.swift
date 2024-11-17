//
//  KeychainAccessible.swift
//  PennMobile
//
//  Created by Josh Doman on 1/1/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

public final class KeychainAccessible: Sendable {

    public static let instance = KeychainAccessible()

    public var pennkeyKeychainKey: String {
        "PennKey"
    }

    public var passwordKeychainKey: String {
        "PennKey Password"
    }

    public var pacCodeKeychainKey: String {
        "PAC Code"
    }

    public var diningTokenKeychainKey: String {
        "Dining Token"
    }

    public func getPennKey() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: pennkeyKeychainKey)
        } catch {
            return nil
        }
    }

    public func getPassword() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: passwordKeychainKey)
        } catch {
            return nil
        }
    }

    public func getPacCode() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: pacCodeKeychainKey)
        } catch {
            return nil
        }
    }

    public func getWebLoginSecureStore() -> SecureStore {
        let genericPwdQueryable = GenericPasswordQueryable(service: "PennWebLogin")
        let secureStore = SecureStore(secureStoreQueryable: genericPwdQueryable)
        return secureStore
    }

    public func getDiningToken() -> String? {
        let secureStore = getWebLoginSecureStore()
        do {
            return try secureStore.getValue(for: diningTokenKeychainKey)
        } catch {
            return nil
        }
    }

}
