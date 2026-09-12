//
//  NetworkingError.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public enum BackendError: Error {
    case clientError(code: Int, response: HTTPURLResponse)
    case serverError(code: Int, response: HTTPURLResponse)
    case unknownError(rawResponse: URLResponse)
}
