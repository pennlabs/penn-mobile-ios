//
//  HomeNewsCell.swift
//  PennMobile
//
//  Created by Josh Doman on 2/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeNewsCell: UITableViewCell, HomeCellConformable {    
    static var identifier: String = "homeNewsCell"
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeNewsCellItem else { return }
            if item.showSubtitle && subtitleLabel == nil {
                self.prepareSubtitleLabel()
            } else if !item.showSubtitle && subtitleLabel != nil {
                subtitleLabel.removeFromSuperview()
                subtitleLabel = nil
            }
            setupCell(with: item)
        }
    }
    
    var article: NewsArticle!
    
    // MARK: Cell Height
    
    static let titleFont: UIFont = UIFont.interiorTitleFont
    static let subtitleFont: UIFont = UIFont.secondaryInformationFont
    
    private static var titleHeightDictionary = [String: CGFloat]()
    private static var subtitleHeightDictionary = [String: CGFloat]()
    
    fileprivate static let showSubtitle = false
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeNewsCellItem else { return 0 }
        let imageHeight = getImageHeight()
        let width: CGFloat = UIScreen.main.bounds.width - (2 * HomeViewController.edgeSpacing) - (2 * Padding.pad)
        
        let titleHeight: CGFloat
        if let height = titleHeightDictionary[item.article.title] {
            titleHeight = height
        } else {
            titleHeight = item.article.title.dynamicHeight(font: titleFont, width: width)
            titleHeightDictionary[item.article.title] = titleHeight
        }
        
        let subtitleHeight: CGFloat
        if !item.showSubtitle {
            subtitleHeight = 0
        } else if let height = subtitleHeightDictionary[item.article.subtitle] {
            subtitleHeight = height
        } else {
            subtitleHeight = item.article.subtitle.dynamicHeight(font: subtitleFont, width: width) + 4
            subtitleHeightDictionary[item.article.subtitle] = subtitleHeight
        }
        let height = imageHeight + titleHeight + subtitleHeight + (5 * Padding.pad)
        return height
    }
    
    // MARK: UI Elements
    var cardView: UIView! = UIView()
    
    fileprivate var articleImageView: UIImageView!
    fileprivate var sourceLabel: UILabel!
    fileprivate var titleLabel: UILabel!
    fileprivate var subtitleLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var moreButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        cardView.addGestureRecognizer(tapGestureRecognizer)
        cardView.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Item
extension HomeNewsCell {
    fileprivate func setupCell(with item: HomeNewsCellItem) {
        self.article = item.article
        self.articleImageView.image = item.image
        self.sourceLabel.text = article.source
        self.titleLabel.text = article.title
        self.subtitleLabel?.text = article.subtitle
        self.dateLabel.text = article.timestamp
    }
}

// MARK: - Gesture Recognizer
extension HomeNewsCell {
    fileprivate func getTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    @objc fileprivate func handleTapped(_ sender: Any) {
        guard let delegate = delegate as? URLSelectable else { return }
        delegate.handleUrlPressed(urlStr: article.articleUrl, title: article.source, item: self.item, shouldLog: true)
    }
}

// MARK: - Prepare UI
extension HomeNewsCell {
    fileprivate func prepareUI() {
        prepareImageView()
        prepareSourceLabel()
        prepareTitleLabel()
        prepareDateLabel()
    }
    
    private func prepareImageView() {
        articleImageView = UIImageView()
        articleImageView.layer.cornerRadius = cardView.layer.cornerRadius
        articleImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        articleImageView.clipsToBounds = true
        articleImageView.contentMode = .scaleAspectFill
        
        cardView.addSubview(articleImageView)
        let height = HomeNewsCell.getImageHeight()
        _ = articleImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    fileprivate static func getImageHeight() -> CGFloat {
        let cardWidth = UIScreen.main.bounds.width - (2 * HomeViewController.edgeSpacing)
        return 0.6 * cardWidth
    }
    
    private func prepareSourceLabel() {
        sourceLabel = UILabel()
        sourceLabel.font = .secondaryInformationFont
        sourceLabel.textColor = UIColor.labelSecondary
        sourceLabel.numberOfLines = 1
        
        cardView.addSubview(sourceLabel)
        _ = sourceLabel.anchor(articleImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: pad, leftConstant: pad, bottomConstant: 0, rightConstant: pad, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = HomeNewsCell.titleFont
        titleLabel.numberOfLines = 8
        
        cardView.addSubview(titleLabel)
        _ = titleLabel.anchor(sourceLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: pad, leftConstant: pad, bottomConstant: 0, rightConstant: pad, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func prepareSubtitleLabel() {
        subtitleLabel = UILabel()
        subtitleLabel.font = HomeNewsCell.subtitleFont
        subtitleLabel.textColor = UIColor.labelSecondary
        subtitleLabel.numberOfLines = 5
        
        cardView.addSubview(subtitleLabel)
        _ = subtitleLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: titleLabel.rightAnchor, topConstant: pad/2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = .secondaryInformationFont
        dateLabel.textColor = UIColor.labelSecondary
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(dateLabel)
        dateLabel.firstBaselineAnchor.constraint(equalTo: sourceLabel.firstBaselineAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: articleImageView.rightAnchor, constant: -pad).isActive = true
    }
}
