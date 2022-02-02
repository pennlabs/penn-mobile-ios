//
//  HomeFeatureCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeFeatureCell: UITableViewCell, HomeCellConformable {    
    static var identifier: String = "homeFeatureCell"
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeFeatureCellItem else { return }
            if item.announcement.description != nil && descriptionLabel == nil {
                self.prepareDescriptionLabel()
            } else if item.announcement.description == nil && descriptionLabel != nil {
                descriptionLabel.removeFromSuperview()
                descriptionLabel = nil
            }
            setupCell(with: item)
        }
    }
    
    var announcement: FeatureAnnouncement!
    
    // MARK: Cell Height
    
    static let titleFont: UIFont = UIFont.primaryInformationFont.withSize(18)
    static let titleEdgeOffset: CGFloat = 16
    
    static let descriptionFont: UIFont = UIFont(name: "HelveticaNeue", size: 14)!
    
    private static var titleHeightDictionary = [String: CGFloat]()
    private static var descriptionHeightDictionary = [String: CGFloat]()
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeFeatureCellItem else { return 0 }
        let imageHeight = getImageHeight()
        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * titleEdgeOffset
        
        let titleHeight: CGFloat
        if let height = titleHeightDictionary[item.announcement.title] {
            titleHeight = height
        } else {
            titleHeight = item.announcement.title.dynamicHeight(font: titleFont, width: width)
            titleHeightDictionary[item.announcement.title] = titleHeight
        }
        
        let height = imageHeight + titleHeight + 48
        guard let description = item.announcement.description else {
            return height
        }
        let descriptionHeight: CGFloat
        if let height = descriptionHeightDictionary[description] {
            descriptionHeight = height
        } else {
            descriptionHeight = description.dynamicHeight(font: descriptionFont, width: width) + 4
            descriptionHeightDictionary[description] = descriptionHeight
        }
        return height + descriptionHeight
    }
    
    // MARK: UI Elements
    
    var cardView: UIView! = UIView()
    
    fileprivate var announcementImageView: UIImageView!
    fileprivate var sourceLabel: UILabel!
    fileprivate var titleLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
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
extension HomeFeatureCell {
    fileprivate func setupCell(with item: HomeFeatureCellItem) {
        self.announcement = item.announcement
        self.announcementImageView.image = item.image
        self.sourceLabel.text = announcement.source
        self.titleLabel.text = announcement.title
        self.descriptionLabel?.text = announcement.description
        self.dateLabel.text = announcement.timestamp
    }
}

// MARK: - Gesture Recognizer
extension HomeFeatureCell {
    fileprivate func getTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    @objc fileprivate func handleTapped(_ sender: Any) {
        guard let delegate = delegate as? FeatureNavigatable else { return }
        delegate.navigateToFeature(feature: announcement.feature, item: self.item)
    }
}

// MARK: - Prepare UI
extension HomeFeatureCell {
    fileprivate func prepareUI() {
        prepareImageView()
        prepareSourceLabel()
        prepareTitleLabel()
        prepareDateLabel()
    }
    
    private func prepareImageView() {
        announcementImageView = UIImageView()
        if #available(iOS 11.0, *) {
            announcementImageView.layer.cornerRadius = cardView.layer.cornerRadius
            announcementImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        announcementImageView.clipsToBounds = true
        announcementImageView.contentMode = .scaleAspectFill
        
        cardView.addSubview(announcementImageView)
        let height = HomeFeatureCell.getImageHeight()
        _ = announcementImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    fileprivate static func getImageHeight() -> CGFloat {
        let cardWidth = UIScreen.main.bounds.width - 40
        return 0.5 * cardWidth
    }
    
    private func prepareSourceLabel() {
        sourceLabel = UILabel()
        sourceLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        sourceLabel.textColor = UIColor.labelSecondary
        sourceLabel.numberOfLines = 1
        
        cardView.addSubview(sourceLabel)
        _ = sourceLabel.anchor(announcementImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 12, leftConstant: HomeFeatureCell.titleEdgeOffset, bottomConstant: 0, rightConstant: HomeFeatureCell.titleEdgeOffset, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = HomeFeatureCell.titleFont
        titleLabel.numberOfLines = 8
        
        cardView.addSubview(titleLabel)
        _ = titleLabel.anchor(sourceLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 8, leftConstant: HomeFeatureCell.titleEdgeOffset, bottomConstant: 0, rightConstant: HomeFeatureCell.titleEdgeOffset, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.font = HomeFeatureCell.descriptionFont
        descriptionLabel.textColor = UIColor.labelSecondary
        descriptionLabel.numberOfLines = 5
        
        cardView.addSubview(descriptionLabel)
        _ = descriptionLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: titleLabel.rightAnchor, topConstant: 6, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        dateLabel.textColor = UIColor.grey1
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(dateLabel)
        dateLabel.centerYAnchor.constraint(equalTo: sourceLabel.centerYAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: announcementImageView.rightAnchor, constant: -HomeFeatureCell.titleEdgeOffset).isActive = true
    }
}

