//
//  Storage.swift
//  PennMobile
//
//  Created by Josh Doman on 11/8/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

// Credit: https://medium.com/@sdrzn/swift-4-codable-lets-make-things-even-easier-c793b6cf29e1

public class Storage {

    fileprivate init() { }

    enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents

        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches

        // Data that is user-generated or cannot be recreated, and is shared with other apps and extensions in the Penn Mobile app group.
        case groupDocuments

        // Data that can be downloaded again or regenerated, and is shared with other apps and extensions in the Penn Mobile app group.
        case groupCaches

        // The search path directory to use.
        var searchPathDirectory: FileManager.SearchPathDirectory? {
            switch self {
            case .documents:
                return .documentDirectory
            case .caches:
                return .cachesDirectory
            default:
                return nil
            }
        }

        // Whether the directory belongs to the App Group.
        var isInGroup: Bool {
            switch self {
            case .groupCaches, .groupDocuments:
                return true
            default:
                return false
            }
        }

        // Path components to append to the container directory.
        var pathComponent: String {
            switch self {
            case .caches, .groupCaches:
                return "Library/Caches"
            case .documents, .groupDocuments:
                return "Documents"
            }
        }
    }

    /// App Group ID
    static let appGroupID = "group.org.pennlabs.PennMobile"

    /// Returns URL constructed from specified directory
    static fileprivate func getURL(for directory: Directory) -> URL {
        if directory.isInGroup {
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?.appendingPathComponent(directory.pathComponent) {
                return url
            }
        } else {
            if let url = FileManager.default.urls(for: directory.searchPathDirectory!, in: .userDomainMask).first {
                return url
            }
        }

        fatalError("Could not create URL for specified directory!")
    }

    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        try! storeThrowing(object, to: directory, as: fileName)
    }
    
    /// Store an encodable struct to the specified directory on disk, throwing if an error occurs.
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    static func storeThrowing<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) throws {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        let encoder = JSONEncoder()
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try encoder.encode(object)
        try data.write(to: url)
    }

    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)

        if !FileManager.default.fileExists(atPath: url.path) {
            clear(directory)
            fatalError("File at path \(url.path) does not exist!")
        }

        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                clear(directory)
                fatalError(error.localizedDescription)
            }
        } else {
            clear(directory)
            fatalError("No data at \(url.path)!")
        }
    }

    /// Retrieve and convert a struct from a file on disk, throwing if an error occurs.
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieveThrowing<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) throws -> T {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }

    /// Remove all files at specified directory
    static func clear(_ directory: Directory) {
        let url = getURL(for: directory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Remove specified file from specified directory
    static func remove(_ fileName: String, from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// Migrate the given file containing the given type to the given directory, if it does not already exist there.
    /// Returns whether the migration happened and succeeded.
    static func migrate<T: Codable>(fileName: String, of type: T.Type, from: Storage.Directory, to: Storage.Directory) -> Bool {
        if !fileExists(fileName, in: to) && fileExists(fileName, in: from) {
            do {
                let record = try retrieveThrowing(fileName, from: from, as: type)
                store(record, to: to, as: fileName)
                remove(fileName, from: from)
                return true
            } catch let error {
                print("Couldn't migrate \(fileName): \(error)")
            }
        }

        return false
    }
}
