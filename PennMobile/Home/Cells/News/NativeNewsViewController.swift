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
        titleLabel.font = UIFont.primaryTitleFont
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
        authorLabel.font = UIFont.primaryInformationFont
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
        var bodyViews: [UIView] = []
        let html = article.data.labsArticle.content
        if let doc = try? SwiftSoup.parse(html), let elements = doc.body()?.children() {
            for element in elements {
                switch element.tagName() {
                case "p":
                    let paragraphTextView = UITextView()
                    paragraphTextView.isScrollEnabled = false
                    paragraphTextView.isEditable = false
                    paragraphTextView.attributedText = try? element.html().htmlToAttributedString
                    paragraphTextView.textColor = .label
                    paragraphTextView.font = UIFont.primaryInformationFont
                    bodyViews.append(paragraphTextView)
                    // TODO: Implement in-text images.
//                case "img":
//                    let imageView = UIImageView()
//                    // Need to check how the source of the image is stored
//                    try? imageView.kf.setImage(with: URL(string: element.attr("src")))
//                    imageView.clipsToBounds = true
//                    imageView.contentMode = .scaleAspectFill
//                    imageView.translatesAutoresizingMaskIntoConstraints = false
//                    bodyViews.append(imageView)
//                    // Not sure if these constraints will work
//                    _ = imageView.anchor(nil, left: contentView.layoutMarginsGuide.leftAnchor, bottom: nil, right: contentView.layoutMarginsGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: contentView.layoutMarginsGuide.layoutFrame.width, heightConstant: contentView.layoutMarginsGuide.layoutFrame.width * 0.6)
                default:
                    print("default")
                }
            }
        }

        for bodyView in bodyViews {
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addArrangedSubview(bodyView)
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                bodyView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
            ])
            bodyView.sizeToFit()
        }
    }
}
