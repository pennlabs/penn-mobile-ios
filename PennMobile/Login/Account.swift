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
        UserDefaults.standard.saveAccount(thisAccount)
    }

    static func getAccount() -> Account? {
        UserDefaults.standard.synchronize()
        return UserDefaults.standard.getAccount()
    }
}

// MARK: - Retrieve Other Account Information
extension Account {
    static func getDiningTransactions() {
        PennCashNetworkManager.instance.getTransactionHistory { data in
            if let data = data, let str = String(bytes: data, encoding: .utf8) {
                UserDBManager.shared.saveTransactionData(csvStr: str)
                UserDefaults.standard.setLastTransactionRequest()
            }
        }
    }

    static func getAndSaveLaundryPreferences() {
        UserDBManager.shared.getLaundryPreferences { rooms in
            if let rooms = rooms {
                UserDefaults.standard.setLaundryPreferences(to: rooms)
            }
        }
    }
    
    static func getAndSaveFitnessPreferences() {
        UserDBManager.shared.getFitnessPreferences { rooms in
            if let rooms = rooms {
                UserDefaults.standard.setFitnessPreferences(to: rooms)
            }
        }
    }

    static func getPacCode() {
        PacCodeNetworkManager.instance.getPacCode { result in
            switch result {
            case .success(let pacCode):
                KeychainAccessible.instance.savePacCode(pacCode)
            case .failure:
                return
            }
        }
    }

    static func getAndSaveNotificationAndPrivacyPreferences(_ completion: @escaping () -> Void) {
        UserDBManager.shared.syncUserSettings { (_) in
            completion()
        }
    }
}

extension Set where Element == Degree {
    func hasDegreeInWharton() -> Bool {
        return self.contains { (degree) -> Bool in
            return degree.schoolCode == "WH"
        }
    }
}
