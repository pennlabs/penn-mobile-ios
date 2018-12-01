//
//  EventNetworkManager.swift
//  PennMobile
//
//  Created by Carin Gan on 11/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class EventNetworkManager: Requestable {
    static let instance = EventNetworkManager()
    private init() {}
    
    fileprivate let eventUrl = "https://platform.pennlabs.org/clubs/events/"
    
    func fetchModel(_ completion: @escaping (_ model: EventTableViewModel?) -> Void) {
        getRequest(url: eventUrl) { (dict) in
            var model: EventTableViewModel? = EventTableViewModel()
            if let dict = dict {
                let json = JSON(dict)
                model = try? EventTableViewModel(json: json)
            }
            completion(model)
        }
    }
}

extension EventTableViewModel {
    convenience init(json: JSON) throws {
        self.init()
        
        guard let eventsJSON = json["events"].array else {
            throw NetworkingError.jsonError
        }
        
        // Initialize empty items
        var eventItems = [HomeEventCellItem]()
        
        // Initialize Event Cells from JSON
        for json in eventsJSON {
            if let item = HomeEventCellItem.getItem(for: json) as? HomeEventCellItem {
                eventItems.append(item)
            }
        }
        
        eventItems.sort()
        self.items = eventItems
    }
}

