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
    static var jsonKey = "gsr-locations"
    static var associatedCell: ModularTableViewCell.Type = HomeGSRLocationsCell.self
    
    static func getHomeCellItem(_ completion: @escaping ([HomeCellItem]) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { token in
            if let token = token {
                
                let request = URLRequest(url: URL(string: "https://pennmobile.org/api/gsr/recent/")!, accessToken: token)
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    if let data = data, let locations = try? decoder.decode([GSRLocation].self, from: data), locations.count > 0 {
                        completion([HomeGSRLocationsCellItem(locations: locations)])
                    } else {
                        completion([])
                    }
                }
                
                task.resume()
            } else {
                if GSRLocationModel.shared.getLocations().count > 2 {
                    let locationSlice = GSRLocationModel.shared.getLocations().shuffle().prefix(upTo: 3)
                    completion([HomeGSRLocationsCellItem(locations: Array(locationSlice))])
                } else {
                    completion([])
                }
            }
        }
    }
    
    let locations: [GSRLocation]
    
    init(locations: [GSRLocation]) {
        self.locations = locations
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeGSRLocationsCellItem else { return false }
        return locations == item.locations
    }
}
