//
//  HomePostCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomePostCell: UITableViewCell, HomeCellConformable {    
    static var identifier: String = "homePostCell"
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomePostCellItem else { return }
            if item.post.subtitle != nil && descriptionLabel == nil {
                self.prepareDescriptionLabel()
            } else if item.post.subtitle == nil && descriptionLabel != nil {
                descriptionLabel.removeFromSuperview()
                descriptionLabel = nil
            }
            setupCell(with: item)
        }
    }
    
    var post: Post!
    
    // MARK: Cell Height
    
    static let titleFont: UIFont = UIFont.primaryInformationFont!.withSize(18)
    static let titleEdgeOffset: CGFloat = 16
    
    static let descriptionFont: UIFont = UIFont(name: "HelveticaNeue", size: 14)!
    
    private static var titleHeightDictionary = [Int: CGFloat]()
    private static var subtitleHeightDictionary = [Int: CGFloat]()
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomePostCellItem else { return 0 }
        let sourceHeight: CGFloat = item.post.source == nil ? 0 : 26
        let imageHeight = getImageHeight()
        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * titleEdgeOffset
        
        let titleHeight: CGFloat
        if let height = titleHeightDictionary[item.post.id] {
            titleHeight = height
        } else if let title = item.post.title {
            let spacing: CGFloat = item.post.source == nil ? 12 : 8
            titleHeight = title.dynamicHeight(font: titleFont, width: width) + spacing
            titleHeightDictionary[item.post.id] = titleHeight
        } else {
            titleHeight = 0.0
        }
        
        let subtitleHeight: CGFloat
        if let height = subtitleHeightDictionary[item.post.id] {
            subtitleHeight = height
        } else if let subtitle = item.post.subtitle {
            subtitleHeight = subtitle.dynamicHeight(font: descriptionFont, width: width) + 6
            subtitleHeightDictionary[item.post.id] = subtitleHeight
        } else {
            subtitleHeight = 0.0
        }
        
        let bottomSpacing: CGFloat = item.post.source == nil && item.post.title == nil ? 0 : 12
        return imageHeight + HomeViewController.cellSpacing + titleHeight + subtitleHeight + sourceHeight + bottomSpacing
    }
    
    // MARK: UI Elements
    
    var cardView: UIView! = UIView()
    
    fileprivate var postImageView: UIImageView!
    fileprivate var sourceLabel: UILabel!
    fileprivate var titleLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var moreButton: UIButton!
    
    fileprivate var titleTopConstraintToImage: NSLayoutConstraint!
    fileprivate var titleTopConstraintToSource: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Item
extension HomePostCell {
    fileprivate func setupCell(with item: HomePostCellItem) {
        self.post = item.post
        self.postImageView.image = item.image
        self.sourceLabel.text = post.source
        self.titleLabel.text = post.title
        self.descriptionLabel?.text = post.subtitle
        self.dateLabel.text = post.timeLabel
        
        if item.post.source == nil {
            titleTopConstraintToSource.isActive = false
            titleTopConstraintToImage.isActive = true
        } else {
            titleTopConstraintToSource.isActive = true
            titleTopConstraintToImage.isActive = false
        }
        
        if item.post.title == nil && item.post.subtitle == nil {
            postImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            postImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
}

// MARK: - Gesture Recognizer
extension HomePostCell {
    fileprivate func getTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    @objc fileprivate func handleTapped(_ sender: Any) {
        guard let delegate = delegate as? URLSelectable, let url = post.postUrl else { return }
        let title: String = url.getMatches(for: "(http(s?):\\/\\/)?(.*?)(.*?)([^a-zA-Z.]|$)").first ?? "View"
        delegate.handleUrlPressed(url: url, title: title, item: self.item, shouldLog: !post.isTest)
    }
}

// MARK: - Prepare UI
extension HomePostCell {
    fileprivate func prepareUI() {
        prepareImageView()
        prepareSourceLabel()
        prepareTitleLabel()
        prepareDateLabel()
    }
    
    private func prepareImageView() {
        postImageView = UIImageView()
        postImageView.layer.cornerRadius = cardView.layer.cornerRadius
        postImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        postImageView.clipsToBounds = true
        postImageView.contentMode = .scaleAspectFill
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        postImageView.addGestureRecognizer(tapGestureRecognizer)
        postImageView.isUserInteractionEnabled = true
        
        cardView.addSubview(postImageView)
        let height = HomePostCell.getImageHeight()
        _ = postImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    fileprivate static func getImageHeight() -> CGFloat {
        let cardWidth = UIScreen.main.bounds.width - 40
        return 0.5 * cardWidth
    }
    
    private func prepareSourceLabel() {
        sourceLabel = UILabel()
        sourceLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        sourceLabel.textColor = UIColor.warmGrey
        sourceLabel.numberOfLines = 1
        
        cardView.addSubview(sourceLabel)
        _ = sourceLabel.anchor(postImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 12, leftConstant: HomePostCell.titleEdgeOffset, bottomConstant: 0, rightConstant: HomePostCell.titleEdgeOffset, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = HomePostCell.titleFont
        titleLabel.numberOfLines = 8
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        titleLabel.addGestureRecognizer(tapGestureRecognizer)
        titleLabel.isUserInteractionEnabled = true
        
        cardView.addSubview(titleLabel)
        titleTopConstraintToSource = titleLabel.anchor(sourceLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 8, leftConstant: HomePostCell.titleEdgeOffset, bottomConstant: 0, rightConstant: HomePostCell.titleEdgeOffset, widthConstant: 0, heightConstant: 0)[0]
        
        titleTopConstraintToImage = titleLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12)
        titleTopConstraintToImage.isActive = false
    }
    
    fileprivate func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.font = HomePostCell.descriptionFont
        descriptionLabel.textColor = UIColor.warmGrey
        descriptionLabel.numberOfLines = 5
        
        cardView.addSubview(descriptionLabel)
        _ = descriptionLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: titleLabel.rightAnchor, topConstant: 6, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        dateLabel.textColor = UIColor.warmGrey
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(dateLabel)
        //        _ = dateLabel.anchor(nil, left: titleLabel.leftAnchor, bottom: cardView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        dateLabel.centerYAnchor.constraint(equalTo: sourceLabel.centerYAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: postImageView.rightAnchor, constant: -HomePostCell.titleEdgeOffset).isActive = true
    }
}
