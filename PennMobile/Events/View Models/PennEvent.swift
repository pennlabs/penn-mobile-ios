//
//  PennEvent.swift
//  PennMobile
//
//  Created by Jacky on 3/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

struct PennEvent: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let image: String
    let location: String
    let category: String
    let path: String
    let start: String
    let end: String
    let starttime: String
    let endtime: String
    let shortdate: String
    let allday: Bool
    let startTimestamp: Int
    let endTimestamp: Int
    let mediaImage: String
    
    // Computed property to convert mediaImage HTML string to a URL
    var mediaImageURL: URL? {
        if let src = mediaImage.slice(from: "src=\"", to: "\""), let url = URL(string: src) {
            return url
        }
        return nil
    }
}

// Helper extension to parse out src attribute from HTML img tag
extension String {
    func slice(from: String, to: String) -> String? {
        (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
