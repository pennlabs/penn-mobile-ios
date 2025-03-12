//
//  HomeGSRLocationsCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 4/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import LabsPlatformSwift

final class HomeGSRLocationsCellItem: HomeCellItem {
    static var jsonKey = "gsr-locations"
    static var associatedCell: ModularTableViewCell.Type = HomeGSRLocationsCell.self

    static func getHomeCellItem(_ completion: @escaping ([HomeCellItem]) -> Void) {
        let url: URL = URL(string: "https://pennmobile.org/api/gsr/recent/")!
        Task {
            guard let request = try? await URLRequest(url: url, mode: .accessToken),
               let (data, response) = try? await URLSession.shared.data(for: request),
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 else {
                    if GSRLocationModel.shared.getLocations().count > 2 {
                        let locationSlice = GSRLocationModel.shared.getLocations().shuffle().prefix(upTo: 3)
                            completion([HomeGSRLocationsCellItem(locations: Array(locationSlice))])
                        } else {
                            completion([])
                        }
                    return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let locations = try? decoder.decode([GSRLocation].self, from: data), locations.count > 0 {
                completion([HomeGSRLocationsCellItem(locations: locations)])
            } else {
                completion([])
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
