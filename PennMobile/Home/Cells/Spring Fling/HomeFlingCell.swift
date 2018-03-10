//
//  HomeFlingCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeFlingCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "homeNewsCell"
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeFlingCellItem else { return }
            setupCell(with: item)
        }
    }
    
    // MARK: Cell Height
    
    static let nameFont: UIFont = UIFont(name: "HelveticaNeue-Bold", size: 18)!
    static let nameEdgeOffset: CGFloat = 16
    
    static let descriptionFont: UIFont = UIFont(name: "HelveticaNeue", size: 14)!
    
    private static var nameHeightDictionary = [String: CGFloat]()
    private static var descriptionHeightDictionary = [String: CGFloat]()
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeFlingCellItem else { return 0 }
        let imageHeight = getImageHeight()
        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * nameEdgeOffset
        
        let nameHeight: CGFloat
        if let height = nameHeightDictionary[item.performer.name] {
            nameHeight = height
        } else {
            nameHeight = item.performer.name.dynamicHeight(font: nameFont, width: width)
            nameHeightDictionary[item.performer.name] = nameHeight
        }
        
        let descriptionHeight: CGFloat
        if let height = descriptionHeightDictionary[item.performer.description] {
            descriptionHeight = height
        } else {
            descriptionHeight = item.performer.description.dynamicHeight(font: descriptionFont, width: width)
            descriptionHeightDictionary[item.performer.description] = descriptionHeight
        }
        return imageHeight + 2 * 20 + nameHeight + descriptionHeight + 60
    }
    
    // MARK: UI Elements
    
    var cardView: UIView! = UIView()
    
    fileprivate var performerImageView: UIImageView!
    fileprivate var performerLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var moreButton: UIButton!
    
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
extension HomeFlingCell {
    fileprivate func setupCell(with item: HomeFlingCellItem) {
        let performer = item.performer
        self.performerImageView.image = item.performer.image
        self.performerLabel.text = performer.name
        self.descriptionLabel.text = performer.description
        self.dateLabel.text = "Today at 7:20pm"
    }
}

// MARK: - Prepare UI
extension HomeFlingCell {
    fileprivate func prepareUI() {
        prepareImageView()
        preparePerformerLabel()
        prepareDescriptionLabel()
        prepareDateLabel()
        // prepareMoreButton()
    }
    
    private func prepareImageView() {
        performerImageView = UIImageView()
        if #available(iOS 11.0, *) {
            performerImageView.layer.cornerRadius = cardView.layer.cornerRadius
            performerImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        performerImageView.clipsToBounds = true
        performerImageView.contentMode = .scaleAspectFill
        
        cardView.addSubview(performerImageView)
        let height = HomeFlingCell.getImageHeight()
        _ = performerImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    fileprivate static func getImageHeight() -> CGFloat {
        let cardWidth = UIScreen.main.bounds.width - 40
        return 0.5 * cardWidth
    }
    
    private func preparePerformerLabel() {
        performerLabel = UILabel()
        performerLabel.font = HomeFlingCell.nameFont
        performerLabel.numberOfLines = 3
        
        cardView.addSubview(performerLabel)
        _ = performerLabel.anchor(performerImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 12, leftConstant: HomeFlingCell.nameEdgeOffset, bottomConstant: 0, rightConstant: HomeFlingCell.nameEdgeOffset, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.font = HomeFlingCell.descriptionFont
        descriptionLabel.textColor = UIColor.warmGrey
        descriptionLabel.numberOfLines = 3
        
        cardView.addSubview(descriptionLabel)
        _ = descriptionLabel.anchor(performerLabel.bottomAnchor, left: performerLabel.leftAnchor, bottom: nil, right: performerLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        dateLabel.textColor = UIColor.warmGrey
        
        cardView.addSubview(dateLabel)
        _ = dateLabel.anchor(nil, left: performerLabel.leftAnchor, bottom: cardView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareMoreButton() {
        moreButton = UIButton(type: .custom)
        moreButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        moreButton.setTitleColor(.warmGrey, for: .normal)
        moreButton.setTitle("See more Fling ->", for: .normal)
        
        cardView.addSubview(moreButton)
        _ = moreButton.anchor(nil, left: nil, bottom: nil, right: performerLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        moreButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
    }
}

extension String {
    // https://stackoverflow.com/questions/34262863/how-to-calculate-height-of-a-string
    func dynamicHeight(font: UIFont, width: CGFloat) -> CGFloat{
        let calString = NSString(string: self)
        let textSize = calString.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        return textSize.height
    }
}
