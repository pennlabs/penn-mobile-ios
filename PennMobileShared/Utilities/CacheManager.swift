//
//  CacheManager.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/30/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

struct CacheManager {
    static let appGroupId = "group.org.pennlabs.PennMobile"
    
    static var cacheDirectory: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupId)?.appendingPathComponent("Cached Results")
    }
    
    static func store<E: PennMobileEndpoint>(request: E, result: E.Response) {
        guard let cacheURL = Self.cacheDirectory?
            .appendingPathComponent("\(request.requestHashKey).pennMobileCached") else { return }
        do {
            try FileManager.default.createDirectory(at: cacheURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(result)
            try data.write(to: cacheURL, options: .atomic)
        } catch {
            return
        }
    }
    
    static func get<E: PennMobileEndpoint>(request: E) -> E.Response? {
        guard case .get(let maxAge?) = request.method,
              let url = Self.cacheDirectory?
            .appendingPathComponent("\(request.requestHashKey).pennMobileCached") else { return nil }

        // store(request:result:) rewrites the file, so its modification date is when the result was cached
        guard let cachedAt = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
              Date().timeIntervalSince(cachedAt) <= maxAge
        else { return nil }

        guard let data = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(E.Response.self, from: data)
        else { return nil }
        
        return response
    }
    
    static func clear<E: PennMobileEndpoint>(request: E) {
        guard let url = Self.cacheDirectory?
            .appendingPathComponent("\(request.requestHashKey).pennMobileCached") else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
