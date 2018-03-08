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
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        let imageHeight = HomeNewsCell.getImageHeight()
        return imageHeight + 40 + 150
    }
    
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
        self.dateLabel.text = "2 hours ago"
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
        newsImageView.layer.cornerRadius = cardView.layer.cornerRadius
        if #available(iOS 11.0, *) {
            newsImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            newsImageView.layer.masksToBounds = true
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
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleLabel.numberOfLines = 3
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        titleLabel.addGestureRecognizer(tapGestureRecognizer)
        titleLabel.isUserInteractionEnabled = true
        
        cardView.addSubview(titleLabel)
        _ = titleLabel.anchor(newsImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 12, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
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
