//
//  Account.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
//
import Foundation
import PennMobileShared
import LabsPlatformSwift

struct Account: Codable, Hashable {
    var pennid: Int
    var firstName: String?
    var lastName: String?
    var username: String
    var email: String?
    var student: Student
    // var imageUrl: String?

    var groups: [String]
    var emails: [Email]

    var isStudent: Bool {
        return groups.contains("student")
    }

    var isInWharton: Bool {
        return student.school.contains(where: { $0.id == 12 })
    }
}

struct Student: Codable, Hashable {
    var major: [Major]
    var school: [School]
    var graduationYear: Int?
}

struct Email: Codable, Hashable {
    var id: Int
    var value: String
    var primary: Bool
    var verified: Bool
}

struct School: Codable, Hashable {
    var id: Int
    var name: String
}

struct Major: Codable, Hashable {
    var id: Int
    var name: String
    var degreeType: String
}

// MARK: - Static Functions
extension Account {
    @MainActor static var isLoggedIn: Bool {
        guard let _ = getAccount() else {
            return false
        }
        if let platform = LabsPlatform.shared, !platform.isLoggedIn {
            return false
        }
        return true
    }

    static func clear() {
        UserDefaults.standard.clearAccount()
        UserDefaults.standard.clearDiningBalance()
        LabsKeychain.clearPlatformCredential()
        LabsKeychain.deletePassword()
        LabsKeychain.deletePennkey()
        KeychainAccessible.instance.removePennKey()
        KeychainAccessible.instance.removePassword()
        KeychainAccessible.instance.removePacCode()
        KeychainAccessible.instance.removeDiningToken()
        Storage.remove(DiningAnalyticsViewModel.dollarHistoryDirectory, from: .documents)
        Storage.remove(DiningAnalyticsViewModel.swipeHistoryDirectory, from: .documents)
        Storage.remove(DiningAnalyticsViewModel.dollarHistoryDirectory, from: .groupDocuments)
        Storage.remove(DiningAnalyticsViewModel.swipeHistoryDirectory, from: .groupDocuments)
        Storage.remove(DiningAnalyticsViewModel.planStartDateDirectory, from: .groupDocuments)
        Storage.remove(DiningBalance.directory, from: .groupCaches)
        Storage.remove(DiningVenue.favoritesDirectory, from: .caches)
    }

    static func saveAccount(_ thisAccount: Account) {
        Task { @MainActor in
            UserDefaults.standard.saveAccount(thisAccount)
        }
    }

    static func getAccount() -> Account? {
        return UserDefaults.standard.getAccount()
    }
}
