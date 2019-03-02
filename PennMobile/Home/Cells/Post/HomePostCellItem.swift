//
//  HomePostCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomePostCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "post"
    }
    
    let post: Post
    var image: UIImage?
    
    init(post: Post) {
        self.post = post
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        return try? HomePostCellItem(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomePostCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomePostCellItem else { return false }
        return post.title == item.post.title
    }
}

// MARK: - HomeAPIRequestable
extension HomePostCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        ImageNetworkingManager.instance.downloadImage(imageUrl: post.imageUrl) { (image) in
            self.image = image
            completion()
        }
    }
}

// MARK: - JSON Parsing
extension HomePostCellItem {
    convenience init(json: JSON) throws {
        let post = try Post(json: json)
        self.init(post: post)
    }
}


