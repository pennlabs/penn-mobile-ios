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
    
    fileprivate var locations = [StudySpace]()
    
    func getLocations() -> [StudySpace] {
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
            let id = json["id"].intValue
            let name = json["name"].stringValue
            let service = json["service"].stringValue
            let location = StudySpace(id: id, name: name, service: service)
            locations.append(location)
        }
        locations.sort { (ss1, ss2) -> Bool in
            return ss1.id < ss2.id
        }
        locations.remove(at: 0) // removes id = 0 (all locations)
    }
}
