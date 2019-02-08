//
//  HomeAPIService.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeAPIService: Requestable {
    static let instance = HomeAPIService()
    private init() {}
        
    func fetchModel(_ completion: @escaping (HomeTableViewModel?) -> Void) {
        let url = "http://api-dev.pennlabs.org/homepage"
        getRequest(url: url) { (dict, error, statusCode) in
            var model: HomeTableViewModel? = HomeTableViewModel()
            if let dict = dict {
                let json = JSON(dict)
                model = try? HomeTableViewModel(json: json)
            }
            completion(model)
        }
    }
}

extension HomeTableViewModel {
    convenience init(json: JSON) throws {
        self.init()
        
        guard let cellsJSON = json["cells"].array else {
            throw NetworkingError.jsonError
        }
        
        self.items = [HomeCellItem]()
        
        // Initialize default items for development
        // Note: this should be empty in production
        for ItemType in HomeItemTypes.instance.getDefaultItems() {
            if let item = ItemType.getItem(for: nil) {
                items.append(item)
            }
        }
        
        // Initialize items from JSON
        for json in cellsJSON {
            let type = json["type"].stringValue
            let infoJSON = json["info"]
            if let ItemType = HomeItemTypes.instance.getItemType(for: type), let item = ItemType.getItem(for: infoJSON) {
                items.append(item)
            }
        }
    }
}

