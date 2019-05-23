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
//        let post = Post(source: "Penn Labs", title: "This is a test with a longer sort of subtitle. What do you think?", subtitle: "This is a subtitle with a really really really long subtitle. We can get crazy long if you really really want. If we do this, will you leave?", timeLabel: "Today", imageUrl: "https://i.imgur.com/CmhAG25.jpg", postUrl: "https://pennlabs.org/", id: 1)
//        let post = Post(source: "Penn Labs", title: "This is a test with a longer sort of subtitle. What do you think?", subtitle: nil, timeLabel: "Today", imageUrl: "https://i.imgur.com/CmhAG25.jpg", postUrl: "https://pennlabs.org/", id: 1)
        let post = Post(source: "Penn Labs", title: nil, subtitle: "This is a subtitle with a really really really long subtitle. We can get crazy long if you really really want. If we do this, will you leave?", timeLabel: "Today", imageUrl: "https://i.imgur.com/CmhAG25.jpg", postUrl: "https://pennlabs.org/", id: 1)
//        let post = Post(source: nil, title: nil, subtitle: nil, timeLabel: nil, imageUrl: "https://i.imgur.com/CmhAG25.jpg", postUrl: "https://pennlabs.org/", id: 1)
        return HomePostCellItem(post: post)
//        guard let json = json else { return nil }
        //return try? HomePostCellItem(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomePostCell.self
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
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

// MARK: - Logging ID
extension HomePostCellItem: LoggingIdentifiable {
    var id: String {
        return String(post.id)
    }
}


