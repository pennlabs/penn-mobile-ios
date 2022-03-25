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
    let scrollView = UIScrollView()
    let contentView = UIView()
    let body = UILabel()
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        prepareScrollView()
        prepareContentView()
        preparetitleLabel()
        prepareBodyText()
    }
    
    func prepareScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    func prepareContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 1000)
        ])
    }
    
    func preparetitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = article.data.labsArticle.headline
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func prepareBodyText() {
        do {
            let html = article.data.labsArticle.content
            let doc: Document = try SwiftSoup.parse(html)
            try body.text = doc.text()
        } catch {
            print(error)
        }
        body.translatesAutoresizingMaskIntoConstraints = false
        body.lineBreakMode = .byWordWrapping
        body.numberOfLines = 0
        contentView.addSubview(body)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            body.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            body.widthAnchor.constraint(equalTo: view.widthAnchor),
            body.heightAnchor.constraint(equalToConstant: 1000),
            body.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            
        ])
    }
}
