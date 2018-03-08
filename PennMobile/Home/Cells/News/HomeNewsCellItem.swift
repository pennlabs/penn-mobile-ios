//
//  HomeNewsCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeNewsCellItem: HomeCellItem {

    static var jsonKey: String {
        return "news"
    }
    
    let article: Article
    var image: UIImage?
    
    init(article: Article) {
        self.article = article
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        let article = Article.getDefaultArticle()
        return HomeNewsCellItem(article: article)
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeNewsCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeNewsCellItem else { return false }
        return article == item.article
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
