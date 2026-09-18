//
//  MultipartError.swift
//  PennMobile
//
//  Created by Anthony Li on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

public enum MultipartError: Error {
    case invalidBoundaryLength
    case invalidBoundaryCharacter
    case invalidContentType
    case invalidName
    case invalidFilename
    case stringEncodingError
}
