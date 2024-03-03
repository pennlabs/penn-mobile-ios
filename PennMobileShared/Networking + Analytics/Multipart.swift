//
//  Multipart.swift
//  PennMobileShared
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

@resultBuilder
public struct MultipartBuilder {
    public static func buildExpression(_ expression: MultipartContent) -> [MultipartContent] {
        [expression]
    }
    
    public static func buildBlock(_ components: [MultipartContent]...) -> [MultipartContent] {
        Array(components.joined())
    }
    
    public static func buildOptional(_ component: [MultipartContent]?) -> [MultipartContent] {
        component ?? []
    }
    
    public static func buildEither(first component: [MultipartContent]) -> [MultipartContent] {
        component
    }
    
    public static func buildEither(second component: [MultipartContent]) -> [MultipartContent] {
        component
    }
    
    public static func buildArray(_ components: [[MultipartContent]]) -> [MultipartContent] {
        Array(components.joined())
    }
    
    public static func buildLimitedAvailability(_ component: [MultipartContent]) -> [MultipartContent] {
        component
    }
}

public enum MultipartError: Error {
    case invalidBoundaryLength
    case invalidBoundaryCharacter
    case invalidContentType
    case invalidName
    case invalidFilename
    case stringEncodingError
}

public struct MultipartBody {
    public static func generateBoundary() -> String {
        UUID().uuidString
    }
    
    public static func escape(string: String) -> String {
        let replaced = string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(replaced)\""
    }
    
    public static let validCharacters = CharacterSet(charactersIn: "-_'").union(.alphanumerics)
    
    public var boundary: String
    public var content: [MultipartContent]
    
    public init(boundary: String = generateBoundary(), content: [MultipartContent]) throws {
        if !(27...70).contains(boundary.count) {
            throw MultipartError.invalidBoundaryLength
        }
        
        if !boundary.unicodeScalars.allSatisfy({ Self.validCharacters.contains($0) }) {
            throw MultipartError.invalidBoundaryCharacter
        }
        
        self.boundary = boundary
        self.content = content
    }
    
    public init(boundary: String = generateBoundary(), @MultipartBuilder _ content: () throws -> [MultipartContent]) throws {
        try self.init(boundary: boundary, content: content())
    }
    
    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
    
    public func assembleData() throws -> Data {
        var data = Data()
        let crlf = "\r\n"
        
        for part in content {
            data.append("--\(boundary)\(crlf)")
            
            if part.type.contains(crlf) {
                throw MultipartError.invalidContentType
            }
            
            if part.name.contains(crlf) {
                throw MultipartError.invalidName
            }
            
            if let filename = part.filename, filename.contains(crlf) {
                throw MultipartError.invalidFilename
            }
            
            var headers = "Content-Type: \(part.type)\(crlf)Content-Disposition: form-data; name=\(Self.escape(string: part.name))"
            if let filename = part.filename {
                headers += "; filename=\(Self.escape(string: filename))"
            }
            headers += "\(crlf)\(crlf)"
            data.append(headers)
            data.append(part.data)
            data.append(crlf)
        }
        
        data.append("--\(boundary)--\(crlf)")
        return data
    }
}
