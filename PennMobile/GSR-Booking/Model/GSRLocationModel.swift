//
//  GSRLocationModel.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

class GSRLocationModel {
    static let shared = GSRLocationModel()
    
    fileprivate var locations = [GSRLocation]()
    
    func getLocations() -> [GSRLocation] {
        return locations
    }
    
    private func fetchJSON() throws -> JSON {
        guard let path = Bundle.main.path(forResource: "locations", ofType: "json") else {
            throw NetworkingError.jsonError
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return JSON(data)
    }
    
    func prepare() {
        guard let json = try? fetchJSON() else { return }
        let locationsJSONArray = json["locations"].arrayValue
        for json in locationsJSONArray {
            let lid = json["lid"].intValue
            let gid = json["gid"].int
            let name = json["name"].stringValue
            let service = json["service"].stringValue
            let location = GSRLocation(lid: lid, gid: gid, name: name, service: service)
            locations.append(location)
        }
    }
}
