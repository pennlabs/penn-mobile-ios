//
//  Optional+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

public extension Optional {
    /// Unwraps an optional and throws an error if it is nil.
    ///
    /// https://www.avanderlee.com/swift/unwrap-or-throw/
    func unwrap(orThrow error: Error) throws -> Wrapped {
        if let self {
            return self
        } else {
            throw error
        }
    }
}
