//
//  NetworkingError.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import LabsPlatformSwift

public enum BackendError: Error {
    case clientError(code: Int, response: HTTPURLResponse)
    case serverError(code: Int, response: HTTPURLResponse)
    case platformError(error: PlatformError)
    case decodingError(error: DecodingError)
    case unknownResponseError(rawResponse: URLResponse)
    case otherError(error: any Error)
}
