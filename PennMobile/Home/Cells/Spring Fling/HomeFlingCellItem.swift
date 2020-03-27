////
////  HomeFlingCellItem.swift
////  PennMobile
////
////  Created by Josh Doman on 3/9/18.
////  Copyright © 2018 PennLabs. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//
//final class HomeFlingCellItem: HomeCellItem {
//
//    static var jsonKey: String {
//        return "fling"
//    }
//
//    let performer: FlingPerformer
//    var image: UIImage?
//    
//    init(performer: FlingPerformer) {
//        self.performer = performer
//    }
//
//    static func getItem(for json: JSON?) -> HomeCellItem? {
//        guard let json = json else { return nil }
//        return try? HomeFlingCellItem(json: json)
//    }
//
//    static var associatedCell: ModularTableViewCell.Type {
//        return HomeFlingCell.self
//    }
//
//    func equals(item: ModularTableViewItem) -> Bool {
//        guard let item = item as? HomeFlingCellItem else { return false }
//        return performer.name == item.performer.name
//    }
//}
//
//// MARK: - HomeAPIRequestable
//extension HomeFlingCellItem: HomeAPIRequestable {
//    func fetchData(_ completion: @escaping () -> Void) {
//        ImageNetworkingManager.instance.downloadImage(imageUrl: performer.imageUrl) { (image) in
//            self.image = image
//            completion()
//        }
//    }
//}
//
//// MARK: - JSON Parsing
//extension HomeFlingCellItem {
//    convenience init(json: JSON) throws {
//        let performer = try FlingPerformer(json: json)
//        self.init(performer: performer)
//    }
//}
//
//// MARK: - Sorting
//extension HomeFlingCellItem: Comparable {
//    static func <(lhs: HomeFlingCellItem, rhs: HomeFlingCellItem) -> Bool {
//        let now = Date()
//        if (lhs.performer.endTime > now && rhs.performer.endTime > now) || (lhs.performer.endTime < now && rhs.performer.endTime < now) {
//            return lhs.performer.startTime < rhs.performer.startTime
//        }
//        return lhs.performer.endTime > now
//    }
//
//    static func ==(lhs: HomeFlingCellItem, rhs: HomeFlingCellItem) -> Bool {
//        return lhs.performer.name == rhs.performer.name && lhs.performer.startTime == rhs.performer.startTime
//    }
//}
//
//extension Array where Element == HomeFlingCellItem {
//    func equals(_ items: [HomeFlingCellItem]) -> Bool {
//        return self.map { $0.performer }.equals(items.map { $0.performer })
//    }
//}
