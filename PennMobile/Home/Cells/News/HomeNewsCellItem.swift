//
//  HomeNewsCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 2/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeNewsCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "news"
    }
    
    let article: NewsArticle
    var image: UIImage?
    var showSubtitle = false
    
    init(article: NewsArticle) {
        self.article = article
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        return try? HomeNewsCellItem(json: json)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeNewsCell.self
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeNewsCellItem else { return false }
        return article.title == item.article.title
    }
}

// MARK: - HomeAPIRequestable
extension HomeNewsCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        ImageNetworkingManager.instance.downloadImage(imageUrl: article.imageUrl) { (image) in
            self.image = image
            completion()
        }
    }
}

// MARK: - JSON Parsing
extension HomeNewsCellItem {
    convenience init(json: JSON) throws {
        let article = try NewsArticle(json: json)
        self.init(article: article)
        self.showSubtitle = json["show_subtitle"].boolValue
    }
}

// MARK: - Logging ID
extension HomeNewsCellItem: LoggingIdentifiable {
    var id: String {
        return article.articleUrl
    }
}
