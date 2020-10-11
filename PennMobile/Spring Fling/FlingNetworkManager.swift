////
////  FlingNetworkManager.swift
////  PennMobile
////
////  Created by Josh Doman on 3/16/18.
////  Copyright © 2018 PennLabs. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//
//final class FlingNetworkManager: Requestable {
//    static let instance = FlingNetworkManager()
//    private init() {}
//
//    fileprivate let flingUrl = "https://api.pennlabs.org/events/fling"
//
//    func fetchModel(_ completion: @escaping (_ model: FlingTableViewModel?) -> Void) {
//        getRequest(url: flingUrl) { (dict, error, statusCode) in
//            var model: FlingTableViewModel? = FlingTableViewModel()
//            if let dict = dict {
//                let json = JSON(dict)
//                model = try? FlingTableViewModel(json: json)
//            }
//            completion(model)
//        }
//    }
//}
//
//extension FlingTableViewModel {
//    convenience init(json: JSON) throws {
//        self.init()
//
//        guard let eventsJSON = json["events"].array else {
//            throw NetworkingError.jsonError
//        }
//
//        // Initialize empty items
//        var flingItems = [HomeFlingCellItem]()
//
//        // Initialize Fling Cells from JSON
//        for json in eventsJSON {
//            if let item = HomeFlingCellItem.getItem(for: json) as? HomeFlingCellItem {
//                flingItems.append(item)
//            }
//        }
//
//        flingItems.sort()
//        self.items = flingItems
//    }
//}
