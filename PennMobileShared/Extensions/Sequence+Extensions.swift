//
//  Sequence+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

public extension Sequence where Element: Sendable {
    /// Maps an array to an array of transformed values, fetched asynchronously in parallel.
    func asyncMap<T: Sendable>(_ transform: @escaping @Sendable (Element) async throws -> T) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: T.self) { group in
            forEach { element in
                group.addTask {
                    try await transform(element)
                }
            }
            
            return try await group.reduce(into: []) { $0.append($1) }
        }
    }
}
