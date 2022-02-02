//
//  HomeNewsCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 2/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeNewsCellItem: HomeCellItem {
    static var jsonKey = "news"
    static var associatedCell: ModularTableViewCell.Type = HomeNewsCell.self
    
    let article: NewsArticle
    var showSubtitle = false
    
    init(for article: NewsArticle) {
        self.article = article
    }
    
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        let task = URLSession.shared.dataTask(with: URL(string: "https://pennmobile.org/api/penndata/news/")!) { data, response, error in
            guard let data = data else { completion([]); return }
            
            if let article = try? JSONDecoder().decode(NewsArticle.self, from: data) {
                completion([HomeNewsCellItem(for: article)])
            } else {
                completion([])
            }
        }
        
        task.resume()
    }

    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeNewsCellItem else { return false }
        return article.title == item.article.title
    }
}

// MARK: - Logging ID
extension HomeNewsCellItem: LoggingIdentifiable {
    var id: String {
        return article.link
    }
}
