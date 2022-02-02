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
        OAuth2NetworkManager.instance.getAccessToken { token in
            guard let token = token else { completion([]); return }

            let url = URLRequest(url: URL(string: "https://pennmobile.org/api/portal/posts/browse/")!, accessToken: token)

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { completion([]); return }

                if let posts = try? JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([Post].self, from: data) {

                    completion(posts.map({return HomePostCellItem(post: $0)}))
                } else {
                    completion([])
                }
            }

            task.resume()
        }
    }

    static var jsonKey: String {
        return "post"
    }

    let post: Post

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
