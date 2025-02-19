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

    func getLocationName(for lid: String, gid: Int?) -> String {
        for location in locations {
            if location.lid == lid && location.gid == gid {
                return location.name
            }
        }
        return ""
    }
    
    
    // JM: this is a bit strange of a design.
    func prepare() {
        DispatchQueue.main.async {
            GSRNetworkManager.instance.getLocations { result in
                switch result {
                case .success(let locations):
                    self.locations = locations
                case .failure:
                    // TODO handle error
                    break
                }
            }
        }
    }
}
