//
//  NativeNewsViewController.swift
//  PennMobile
//
//  Created by Kunli Zhang on 27/02/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

class NativeNewsViewController: UIViewController {
    var article: NewsArticle!
    let content = UILabel()
    let titleLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        preparetitleLabel()
        prepareBodyText()
    }
    func preparetitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = article.data.labsArticle.headline
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    func prepareBodyText() {
        do {
            let html = article.data.labsArticle.content
            let doc: Document = try SwiftSoup.parse(html)
            try content.text = doc.text()
        } catch {
            print(error)
        }
        content.translatesAutoresizingMaskIntoConstraints = false
        content.lineBreakMode = .byWordWrapping
        content.numberOfLines = 0
        view.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: titleLabel.layoutMarginsGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
