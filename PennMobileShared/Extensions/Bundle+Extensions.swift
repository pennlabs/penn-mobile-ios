//
//  Bundle+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

// Decodes .json data for SwiftUI Previews
// https://www.hackingwithswift.com/books/ios-swiftui/using-generics-to-load-any-kind-of-codable-data
public extension Bundle {
    func decode<T: Codable>(_ file: String, dateFormat: String? = nil) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("unable to find data")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        guard let decoded = try? decoder.decode(T.self, from: data) else {
            fatalError("Data does not conform to desired structure")
        }
        
        return decoded
    }
}
