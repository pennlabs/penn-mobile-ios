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
        guard let json = json else { return nil }
        return try? HomeNewsCellItem(json: json)
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

// MARK: JSON Parsing
extension HomeNewsCellItem {
    convenience init(json: JSON) throws {
        let data = try json.rawData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw NetworkingError.invalidDate
        })
        let article = try decoder.decode(Article.self, from: data)
        self.init(article: article)
    }
}
