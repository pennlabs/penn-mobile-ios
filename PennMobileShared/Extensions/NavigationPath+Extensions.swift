//
//  NavigationPath+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import SwiftUI

/// This is used to get the current navigation path in a readable format. For example, if SomePage is a Codable enum
/// that is the type of the values used in any NavigationLink, then calling asList(of: SomePage.self) will return
/// the current NavigationPath as [SomePage] (but optional in case of failure)
/// This is very jank, so if someone else knows a better way, PLEASE change this.
public extension NavigationPath {
    func getData() -> Data? {
        guard let representation = self.codable else { return nil }
        let encoder = JSONEncoder()
        return try? encoder.encode(representation)
    }
    
    func asList<R: Decodable>(of type: R.Type) -> [R]? {
        guard let data = getData() else { return nil }
        let decoder = JSONDecoder()
        guard let pageArray = try? decoder.decode([String].self, from: data) else { return nil }
        let output: [R] = pageArray.compactMap {
            guard let data = $0.data(using: .utf8) else { return nil }
            return try? decoder.decode(type, from: data)
        }
        return output
    }
    
    func contains<R: Decodable & Equatable>(_ page: R) -> Bool {
        return asList(of: R.self)?.contains(page) ?? false
    }
    
    mutating func removeAll() {
        self.removeLast(self.count)
    }
}
