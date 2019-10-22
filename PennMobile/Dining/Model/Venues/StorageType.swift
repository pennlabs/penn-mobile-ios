//
//  StorageType.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

enum StorageType {
    case cache // Can be cleared by system
    case permanant // Never cleared
    
    var searchPathDirectory: FileManager.SearchPathDirectory {
        switch self {
        case .cache: return .cachesDirectory
        case .permanant: return .documentDirectory
        }
    }
    
    var folder: URL {
        let path = NSSearchPathForDirectoriesInDomains(searchPathDirectory, .userDomainMask, true).first!
        let subfolder = "org.pennlabs.PennMobile.json_storage"
        return URL(fileURLWithPath: path).appendingPathComponent(subfolder)
    }
    
    func clearStorage() {
        try? FileManager.default.removeItem(at: folder)
    }
}

class LocalJSONStore<T> where T : Codable {
    let storageType: StorageType
    let filename: String
    
    init(storageType: StorageType, filename: String) {
        self.storageType = storageType
        self.filename = filename
        ensureFolderExists()
    }
    
    // MARK: - Saving
    func save(_ object: T) {
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL)
        } catch let e {
            print("CACHE ERROR: \(e)")
        }
    }
    
    var storedValue: T? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let e {
            // This error will happen when our Codable representations change. This is okay, the cache will overwrite old structures eventually.
            print("CACHE DECODING ERROR (CODABLE may have changed): \(e)")
            return nil
        }
    }
    
    // MARK: - Retrieving
    
    private var folder: URL {
        return storageType.folder
    }
    
    private var fileURL: URL {
        return folder.appendingPathComponent(filename)
    }
    
    private func ensureFolderExists() {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: folder.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return
            }
            try? FileManager.default.removeItem(at: folder)
        }
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: false, attributes: nil)
    }
}
