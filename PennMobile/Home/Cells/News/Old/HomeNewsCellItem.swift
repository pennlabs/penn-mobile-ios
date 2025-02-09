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
    var showSubtitle = true

    init(for article: NewsArticle) {
        self.article = article
    }

    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        let task = URLSession.shared.dataTask(with: URL(string: "https://labs-graphql-295919.ue.r.appspot.com/graphql?query=%7BlabsArticle%7Bslug,headline,abstract,published_at,authors%7Bname%7D,dominantMedia%7BimageUrl,authors%7Bname%7D%7D,tag,content%7D%7D")!) { data, _, _ in
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
        return article.data.labsArticle.headline == item.article.data.labsArticle.headline
    }
}

// MARK: - Logging ID
extension HomeNewsCellItem: LoggingIdentifiable {
    var id: String {
        return article.data.labsArticle.slug
    }
}
