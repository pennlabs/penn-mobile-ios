//
//  Article.swift
//  PennMobile
//
//  Created by Josh Doman on 3/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
//
//  Article.swift
//  PennMobile
//
//  Created by Josh Doman on 3/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation

class Article: Decodable {
    let source: String
    let title: String
    let date: Date
    let imageUrl: String
    let articleUrl: String
    
    init(source: String, title: String, date: Date, imageUrl: String, articleUrl: String) {
        self.source = source
        self.title = title
        self.date = date
        self.imageUrl = imageUrl
        self.articleUrl = articleUrl
    }
    
    static func getDefaultArticle() -> Article {
        let source = "The Daily Pennsylvanian"
        let title = "Penn's cost of attendance will exceed $70,000 next year — a 3.8 percent increase"
        let date = Date()
        let imageUrl = "http://snworksceo.imgix.net/dpn/66799ad7-5e72-4759-9d4e-33a62308bdce.sized-1000x1000.jpg"
        let articleUrl = "http://www.thedp.com/article/2018/03/university-penn-president-amy-gutmann-wendell-pritchett-budget-board-trustees-tuition-increase-financial-aid"
        return Article(source: source, title: title, date: date, imageUrl: imageUrl, articleUrl: articleUrl)
    }
}

extension Article: Equatable {
    static func ==(lhs: Article, rhs: Article) -> Bool {
        return lhs.source == rhs.source &&
            lhs.title == rhs.title &&
            lhs.date == rhs.date &&
            lhs.imageUrl == rhs.imageUrl &&
            lhs.articleUrl == rhs.articleUrl
    }
}
