//
//  HomeGSRLocationsCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 4/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeGSRLocationsCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeGSRLocationsCell.self
    }
    
    let locations: [GSRLocation]
    
    init(locations: [GSRLocation]) {
        self.locations = locations
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeGSRLocationsCellItem else { return false }
        return locations == item.locations
    }
    
    static var jsonKey: String {
        return "gsr-locations"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        let locations = GSRLocationModel.shared.getLocations().filter { [1, 1889, 4368].contains($0.gid!) }
        return HomeGSRLocationsCellItem(locations: locations)
    }
}
