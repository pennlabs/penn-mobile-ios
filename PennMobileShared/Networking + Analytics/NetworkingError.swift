//
//  NetworkingError.swift
//  PennMobile
//
//  Created by Anthony Li on 11/5/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

public enum NetworkingError: LocalizedError {
    case noInternet
    case parsingError
    case serverError
    case jsonError
    case authenticationError
    case alreadyExists
    case other
    
    public var errorDescription: String? {
        let localizationValue: String.LocalizationValue = switch self {
        case .noInternet:
            "The Internet connection appears to be offline. Connect to the Internet, then try again."
        case .parsingError:
            "The server returned an invalid response. Please report this error."
        case .serverError:
            "The operation couldn't be completed due to a server error. Please report this error."
        case .jsonError:
            "The server returned a response that didn't match the expected JSON format. Please report this error."
        case .authenticationError:
            "There was an authentication error. Try signing out, then signing in again."
        case .alreadyExists:
            "This offer already exists."
        case .other:
            "An unknown networking error occurred. Please report this error."
        }
        
        return String(localized: localizationValue)
    }
}
