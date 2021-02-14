//
//  LocalJSONStore.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/22/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// MARK: - LocalJSONStore
// This class can be used by any Codable struct as a simple cacheing layer. Check out DiningDataStore.swift for an example.
class LocalJSONStore<T> where T : Codable {
    let storageType: DataStoreType
    let filename: String
    
    init(storageType: DataStoreType, filename: String) {
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
            // This error happens when we fail to encode our object as JSON. This means we made a mistake in one of our encode(:) implementations. For example, if we try to encode a field whose value is optional and is nil, without using encodeIfPresent().
            print("CACHE ERROR: \(e)")
        }
    }
    
    // MARK: - Loading
    var storedValue: T? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let e {
            // This error will happen when our Codable representations change and we try to read an old format from the cache. This is okay, the cache will overwrite old structures eventually.
            print("CACHE DECODING ERROR (CODABLE may have changed): \(e)")
            return nil
        }
    }
    
    // MARK: - Helpers
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
