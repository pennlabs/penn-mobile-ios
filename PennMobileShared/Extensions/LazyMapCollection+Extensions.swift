//
//  LazyMapCollection+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

public extension LazyMapCollection {
    func toArray() -> [Element] {
        return Array(self)
    }
}
