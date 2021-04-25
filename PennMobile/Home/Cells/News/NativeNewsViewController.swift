//
//  NativeNewsViewController.swift
//  Penn Mobile
//
//  Created by Daniel Duan on 11/1/20.
//

import UIKit
import SwiftSoup
import Kingfisher

class NativeNewsViewController: UIViewController {
    
    func textViewTemplate(for content: String) -> UILabel {
        let textLabel = UILabel()
        textLabel.font = UIFont.init(name: "NewYork", size: 20)
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        textLabel.text = content
        return textLabel
    }
    
    func imgViewTemplate(imageURL: String, caption: String) -> UIView {

        let imgWithCaptionView = UIView()
        
        let imgView = UIImageView()
        let url = URL(string: imageURL)
         
        let captionLabel = UILabel()
        captionLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 0
        captionLabel.text = caption
        
        imgWithCaptionView.addSubview(imgView)
        imgWithCaptionView.addSubview(captionLabel)
        
        // autolayout constraints for image view
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.leadingAnchor.constraint(equalTo: imgWithCaptionView.leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: imgWithCaptionView.trailingAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: imgWithCaptionView.topAnchor).isActive = true
        
        imgView.kf.setImage(with: url, completionHandler:  { result in
            if let value = try? result.get() {
                let ratio = value.image.size.height / value.image.size.width
                imgView.heightAnchor.constraint(equalTo: imgWithCaptionView.widthAnchor, multiplier: ratio).isActive = true
            }
        })
        
        // autolayout constraints for caption label
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.leadingAnchor.constraint(equalTo: imgWithCaptionView.leadingAnchor).isActive = true
        captionLabel.trailingAnchor.constraint(equalTo: imgWithCaptionView.trailingAnchor).isActive = true
        captionLabel.bottomAnchor.constraint(equalTo: imgWithCaptionView.bottomAnchor).isActive = true
        captionLabel.topAnchor.constraint(equalToSystemSpacingBelow: imgView.bottomAnchor, multiplier: 0.5).isActive = true
        
        imgView.contentMode = .scaleAspectFit
        return imgWithCaptionView
    }
    
    func titleViewTemplate(forTitle title: String, forAuthor author: String) -> UIView {
        
        let titleAndAuthorView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        
        let authorLabel = UILabel()
        authorLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        authorLabel.textAlignment = .left
        authorLabel.numberOfLines = 0
        authorLabel.text = author
        
        titleAndAuthorView.addSubview(titleLabel)
        titleAndAuthorView.addSubview(authorLabel)
        
        // autolayout constraints for titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: titleAndAuthorView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: titleAndAuthorView.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: titleAndAuthorView.topAnchor).isActive = true
        
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.leadingAnchor.constraint(equalTo: titleAndAuthorView.leadingAnchor).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo: titleAndAuthorView.trailingAnchor).isActive = true
        authorLabel.bottomAnchor.constraint(equalTo: titleAndAuthorView.bottomAnchor).isActive = true
        authorLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 0.5).isActive = true
        
        return titleAndAuthorView
    }
    
    var viewContent = [UIView]()
    let scrollView = UIScrollView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .uiBackground
        prepareScrollView()
        loadContent()
    }
        
    func fetchData(for url: String) {
        let myURL = URL(string: url)!
        let html = try! String(contentsOf: myURL, encoding: .utf8)

        guard let doc = try? SwiftSoup.parseBodyFragment(html) else { return }

        guard let link = try? doc.select("article").first() else { return }
        
        guard let children = link?.children() else { return }
        
        for element in children {
            switch element.tagName() {
            case "div":
                guard let className = try? element.className() else { return }
                if className == "article-metadata" {
                    guard let title = try? element.select("h1").first()?.text() else { return }
                    guard let authorName = try? element.select("span.byline").first()?.text() else { return }
                    guard let date = try? element.select("span.dateline").first()?.text() else { return }
                    
                    let authorStr = "\(authorName ?? "The Daily Pennsylvania") | \(date ?? "")"
                    
                    viewContent.append(titleViewTemplate(forTitle: title!, forAuthor: authorStr))

                }
            case "figure":
                guard let className = try? element.className() else { return }
                if (className == "dominant-media") {
                    guard let imgLink = try? element.select("a").first()?.select("img").attr("src") else { return }
                    guard let captionStr = try? element.select("figcaption").first()?.text() else { return }
                    viewContent.append(imgViewTemplate(imageURL: imgLink!, caption: captionStr!))
                } else {
                    guard let imgLink = try? element.select("img").first()?.attr("src") else { return }
                    guard let captionStr = try? element.select("figcaption").first()?.text() else { return }
                    viewContent.append(imgViewTemplate(imageURL: imgLink!, caption: captionStr!))
                }

            case "p":
                guard let paragraphText = try? element.text() else { return }
                viewContent.append(textViewTemplate(for: paragraphText))
            default:
                continue
            }
        }

    }

    func prepareScrollView() {
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false;

        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true;
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        scrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true;
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        scrollView.addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false;
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.pad).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.pad).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Padding.pad * 2).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(Padding.pad * 2)).isActive = true
    }

    func loadContent() {

        for (n, content) in viewContent.enumerated() {
            contentView.addSubview(content);
            content.translatesAutoresizingMaskIntoConstraints = false

            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true

            if n == 0 {
                content.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            } else {
                content.topAnchor.constraint(equalToSystemSpacingBelow: viewContent[n - 1].bottomAnchor, multiplier: 1.0).isActive = true
            }

            if (n == viewContent.count - 1) {
                content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            }
        }
    }
}
