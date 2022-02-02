//
//  PennEvents.swift
//  PennMobile
//
//  Created by Samantha Su on 10/1/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation

struct PennEvents: Codable {
    static let directory = "events.json"

    let id: String
    let title: String
    let body: String
    let image: String
    let location: StringOrBool
    let category: String
    let path: String
    let start: Date?
    let end: Date?
    let starttime: String
    let endtime: String
    let allday: String
    var media_image: String
    let shortdate: String

    var isAllDay: Bool {
        return allday == "All day"
    }
}

struct StringOrBool: Codable{
    var value: String?
      init(from decoder: Decoder) throws {
        if let string = try? String(from: decoder) {
          value = string
          return
        }
        value = nil
      }
}
