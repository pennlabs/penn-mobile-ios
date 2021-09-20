//
//  HomeGSRLocationsCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 4/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeGSRLocationsCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeGSRLocationsCell.self
    }
    
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        completion([])
    }
    
    let locations: [GSRLocation]
    
    init(locations: [GSRLocation]) {
        self.locations = locations
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeGSRLocationsCellItem else { return false }
        return locations == item.locations
    }
    
    static var jsonKey: String {
        return "gsr-locations"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let lids = json?.arrayObject as? [Int] else { return nil }
        var locations = GSRLocationModel.shared.getLocations().filter { lids.contains( $0.lid ) }
        locations = locations.filter { $0.lid != 1086 || $0.gid == 1889 }
        return HomeGSRLocationsCellItem(locations: locations)
    }
}
