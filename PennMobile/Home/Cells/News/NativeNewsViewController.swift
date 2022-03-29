//
//  NativeNewsViewController.swift
//  PennMobile
//
//  Created by Kunli Zhang on 27/02/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup
import UIKit

class NativeNewsViewController: UIViewController {
    var article: NewsArticle!
    let scrollView = UIScrollView()
    let contentView = UIStackView()
    let body = UILabel()
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    let imageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        prepareScrollView()
        prepareContentView()
        prepareTitleLabel()
        prepareAuthorLabel()
        prepareImageView()
        prepareBodyText()
    }
    func prepareScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor)
        ])
    }
    func prepareContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = NSLayoutConstraint.Axis.vertical
        contentView.distribution = UIStackView.Distribution.equalSpacing
        contentView.alignment = UIStackView.Alignment.leading
        contentView.spacing = 16.0
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    func prepareTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = article.data.labsArticle.headline
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        contentView.addArrangedSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    func prepareAuthorLabel() {
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.text = ""
        for author in article.data.labsArticle.authors {
            authorLabel.text! += author.name + ", "
        }
        authorLabel.text?.removeLast(2)
        authorLabel.text! += " | " + article.data.labsArticle.published_at
        authorLabel.lineBreakMode = .byWordWrapping
        authorLabel.numberOfLines = 0
        authorLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        contentView.addArrangedSubview(authorLabel)
        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    func prepareImageView() {
        imageView.kf.setImage(with: URL(string: article.data.labsArticle.dominantMedia.imageUrl))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addArrangedSubview(imageView)
        _ = imageView.anchor(nil, left: contentView.layoutMarginsGuide.leftAnchor, bottom: nil, right: contentView.layoutMarginsGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: contentView.layoutMarginsGuide.layoutFrame.width, heightConstant: contentView.layoutMarginsGuide.layoutFrame.width * 0.6)
    }
    
    func prepareBodyText() {
        do {
            let html = article.data.labsArticle.content
            let doc: Document = try SwiftSoup.parse(html)
            var element = try doc.select("p").first()!
            body.text = ""
            while true {
                guard let sibling = try element.nextElementSibling() else { break }
                if sibling.tagName() != "p" { break }
                body.text! += try sibling.text() + "\n \n"
                element = sibling
            }
        } catch {
            print(error)
        }
        body.translatesAutoresizingMaskIntoConstraints = false
        body.lineBreakMode = .byWordWrapping
        body.numberOfLines = 0
        contentView.addArrangedSubview(body)
        NSLayoutConstraint.activate([
            body.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
