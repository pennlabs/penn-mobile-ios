//
//  MultipartContent.swift
//  PennMobile
//
//  Created by Anthony Li on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public struct MultipartContent {
    public var type: String
    public var name: String
    public var filename: String?
    public var data: Data
    
    public init(type: String, name: String, filename: String? = nil, data: Data) {
        self.type = type
        self.name = name
        self.filename = filename
        self.data = data
    }
    
    public init(type: String, name: String, filename: String? = nil, data: () -> Data) {
        self.init(type: type, name: name, filename: filename, data: data())
    }
    
    public init(name: String, content: String) throws {
        let converted = content.split(separator: /\r|\n|\r\n/).joined(separator: "\r\n")
        let data = try converted.data(using: .utf8).unwrap(orThrow: MultipartError.stringEncodingError)
        
        self.init(type: "text/plain", name: name, data: data)
    }
}
