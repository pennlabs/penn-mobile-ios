//
//  StorageType.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// MARK: - Data Store Types
enum DataStoreType {
    case cache // Can be cleared by system
    case permanant // Never cleared

    var searchPathDirectory: FileManager.SearchPathDirectory {
        switch self {
        case .cache: return .cachesDirectory
        case .permanant: return .documentDirectory
        }
    }

    var folder: URL {
        let path = NSSearchPathForDirectoriesInDomains(searchPathDirectory, .userDomainMask, true).first ?? ""
        let subfolder = "org.pennlabs.PennMobile.json_storage"
        return URL(fileURLWithPath: path).appendingPathComponent(subfolder)
    }

    func clearStorage() {
        try? FileManager.default.removeItem(at: folder)
    }
}
