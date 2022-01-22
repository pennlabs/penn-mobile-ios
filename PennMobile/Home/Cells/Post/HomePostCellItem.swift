//
//  HomePostCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

final class HomePostCellItem: HomeCellItem {
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        let url = URL(string: "https://pennmobile.org/api/portal/posts/")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { completion([]); return }
            
            if let article = try? JSONDecoder().decode(NewsArticle.self, from: data) {
                completion([HomeNewsCellItem(for: article)])
            } else {
                completion([])
            }
        }
        
        task.resume()
    }
    
    static var jsonKey: String {
        return "post"
    }
    
    let post: Post
    var image: UIImage?
    
    init(post: Post) {
        self.post = post
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomePostCell.self
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomePostCellItem else { return false }
        return post.title == item.post.title
    }
}

// MARK: - Logging ID
extension HomePostCellItem: LoggingIdentifiable {
    var id: String {
        return String(post.id)
    }
}
