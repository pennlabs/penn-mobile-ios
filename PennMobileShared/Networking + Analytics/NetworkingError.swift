//
//  NetworkingError.swift
//  PennMobile
//
//  Created by Anthony Li on 11/5/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

public enum NetworkingError: String, Error {
    case noInternet
    case parsingError
    case serverError
    case jsonError = "JSON error"
    case authenticationError = "Unable to authenticate"
    case other
    var localizedDescription: String { self.rawValue }
}
