//
//  Data+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

public extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
    
    var hexString: String {
        map { String(format: "%02.2hhx", $0) }.joined()
    }
}
