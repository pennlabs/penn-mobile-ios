//
//  HomeNewsCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

import Foundation

protocol NewsCellDelegate {
    func handleArticleTapped(_ article: Article)
}

final class HomeNewsCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "homeNewsCell"

    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeNewsCellItem else { return }
            setupCell(with: item)
        }
    }
    
    // MARK: Cell Height
    
    static let titleFont: UIFont = UIFont(name: "HelveticaNeue-Bold", size: 18)!
    static let titleEdgeOffset: CGFloat = 16
    
    private static var titleHeightDictionary = [String: CGFloat]()
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeNewsCellItem else { return 0 }
        let imageHeight = getImageHeight()
        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * titleEdgeOffset
        let titleHeight: CGFloat
        if let height = titleHeightDictionary[item.article.title] {
            titleHeight = height
        } else {
            titleHeight = item.article.title.dynamicHeight(font: titleFont, width: width)
            titleHeightDictionary[item.article.title] = titleHeight
        }
        return imageHeight + 2 * 20 + titleHeight + 80
    }
    
    // MARK: Properties
    
    fileprivate var article: Article!
    
    var cardView: UIView! = UIView()
    
    fileprivate var newsImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var sourceLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var heartButton: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Item
extension HomeNewsCell {
    fileprivate func setupCell(with item: HomeNewsCellItem) {
        self.article = item.article
        self.newsImageView.image = item.image
        self.titleLabel.text = article.title
        self.sourceLabel.text = article.source
        self.dateLabel.text = getDateString(for: article.date)
    }
    
    private func getDateString(for date: Date) -> String {
        let now = Date()
        guard let days = now.daysFrom(date: date) else { return "" }
        if days == 0 {
            let minutes = now.minutesFrom(date: date)
            if minutes <= 5 {
                return "Just now"
            } else if minutes < 60 {
                return "\(minutes) minutes ago"
            } else {
                let hours = minutes / 60
                return "\(hours) hours ago"
            }
        } else if days == 1 {
            return "1 day ago"
        } else if days > 1 && days < 7 {
            return "\(days) days ago"
        } else if days >= 7 {
            let weeks = days / 7
            if weeks == 1 {
                return "1 week ago"
            } else {
                return "\(weeks) weeks ago"
            }
        }
        return ""
    }
}

// MARK: - Selection
extension HomeNewsCell {
    @objc fileprivate func handleTapped(_ sender: Any) {
        guard let delegate = delegate as? NewsCellDelegate else { return }
        delegate.handleArticleTapped(article)
    }
}

// MARK: - Gesture Recognizer
extension HomeNewsCell {
    fileprivate func getTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
}

// MARK: - Prepare UI
extension HomeNewsCell {
    fileprivate func prepareUI() {
        prepareImageView()
        prepareTitleLabel()
        prepareSourceLabel()
        prepareDateLabel()
        prepareHeart()
    }
    
    private func prepareImageView() {
        newsImageView = UIImageView()
        if #available(iOS 11.0, *) {
            newsImageView.layer.cornerRadius = cardView.layer.cornerRadius
            newsImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        newsImageView.clipsToBounds = true
        newsImageView.contentMode = .scaleAspectFill
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        newsImageView.addGestureRecognizer(tapGestureRecognizer)
        newsImageView.isUserInteractionEnabled = true
        
        cardView.addSubview(newsImageView)
        let height = HomeNewsCell.getImageHeight()
        _ = newsImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    fileprivate static func getImageHeight() -> CGFloat {
        let cardWidth = UIScreen.main.bounds.width - 40
        return 0.5 * cardWidth
    }
    
    private func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = HomeNewsCell.titleFont
        titleLabel.numberOfLines = 3
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        titleLabel.addGestureRecognizer(tapGestureRecognizer)
        titleLabel.isUserInteractionEnabled = true
        
        cardView.addSubview(titleLabel)
        _ = titleLabel.anchor(newsImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 12, leftConstant: HomeNewsCell.titleEdgeOffset, bottomConstant: 0, rightConstant: HomeNewsCell.titleEdgeOffset, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareSourceLabel() {
        sourceLabel = UILabel()
        sourceLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        sourceLabel.textColor = UIColor.warmGrey
        
        cardView.addSubview(sourceLabel)
        _ = sourceLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        dateLabel.textColor = UIColor.warmGrey
        
        cardView.addSubview(dateLabel)
        _ = dateLabel.anchor(nil, left: titleLabel.leftAnchor, bottom: cardView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareHeart() {
        let image = UIImage(named: "heart")
        heartButton = UIImageView(image: image)
        heartButton.tintColor = UIColor.red
        
        cardView.addSubview(heartButton)
        _ = heartButton.anchor(nil, left: nil, bottom: cardView.bottomAnchor, right: titleLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 16, widthConstant: 20, heightConstant: 20)
    }
}
