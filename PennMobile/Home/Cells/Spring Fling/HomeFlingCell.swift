////
////  HomeFlingCell.swift
////  PennMobile
////
////  Created by Josh Doman on 3/9/18.
////  Copyright © 2018 PennLabs. All rights reserved.
////
//
//import Foundation
//
//final class HomeFlingCell: UITableViewCell, HomeCellConformable {    
//    static var identifier: String = "flingCell"
//    
//    var delegate: ModularTableViewCellDelegate!
//    var item: ModularTableViewItem! {
//        didSet {
//            guard let item = item as? HomeFlingCellItem else { return }
//            setupCell(with: item)
//        }
//    }
//    
//    var performer: FlingPerformer!
//    
//    // MARK: Cell Height
//    
//    static let nameFont: UIFont = UIFont(name: "HelveticaNeue-Bold", size: 18)!
//    static let nameEdgeOffset: CGFloat = 16
//    
//    static let descriptionFont: UIFont = UIFont(name: "HelveticaNeue", size: 14)!
//    
//    private static var nameHeightDictionary = [String: CGFloat]()
//    private static var descriptionHeightDictionary = [String: CGFloat]()
//    
//    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
//        guard let item = item as? HomeFlingCellItem else { return 0 }
//        let imageHeight = getImageHeight()
//        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * nameEdgeOffset
//        
//        let nameHeight: CGFloat
//        if let height = nameHeightDictionary[item.performer.name] {
//            nameHeight = height
//        } else {
//            nameHeight = item.performer.name.dynamicHeight(font: nameFont, width: width)
//            nameHeightDictionary[item.performer.name] = nameHeight
//        }
//        
//        let descriptionHeight: CGFloat
//        if let height = descriptionHeightDictionary[item.performer.description] {
//            descriptionHeight = height
//        } else {
//            descriptionHeight = item.performer.description.dynamicHeight(font: descriptionFont, width: width)
//            descriptionHeightDictionary[item.performer.description] = descriptionHeight
//        }
//        let height = imageHeight + nameHeight + descriptionHeight + 60
//        return height
//    }
//    
//    // MARK: UI Elements
//    
//    var cardView: UIView! = UIView()
//    
//    fileprivate var performerImageView: UIImageView!
//    fileprivate var performerLabel: UILabel!
//    fileprivate var descriptionLabel: UILabel!
//    fileprivate var dateLabel: UILabel!
//    fileprivate var moreButton: UIButton!
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        prepareHomeCell()
//        prepareUI()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//// MARK: - Setup Item
//extension HomeFlingCell {
//    fileprivate func setupCell(with item: HomeFlingCellItem) {
//        self.performer = item.performer
//        self.performerImageView.image = item.image
//        self.performerLabel.text = performer.name
//        self.descriptionLabel.text = performer.description
//        self.dateLabel.text = getDateString(for: performer)
//    }
//    
//    private func getDateString(for performer: FlingPerformer) -> String {
//        let now = Date()
//        if performer.startTime < now && now < performer.endTime {
//            return "Happening now"
//        }
//        
//        let formatter = DateFormatter()
//        formatter.amSymbol = "am"
//        formatter.pmSymbol = "pm"
//        formatter.dateFormat = "h:mma"
//        
//        var prelude = "Starting"
//        if performer.startTime.isToday {
//            prelude = "Today"
//        }
//        
//        return "\(prelude) at \(formatter.string(from: performer.startTime))"
//    }
//}
//
//// MARK: - Gesture Recognizer
//extension HomeFlingCell {
//    fileprivate func getTapGestureRecognizer() -> UITapGestureRecognizer {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        return tapGestureRecognizer
//    }
//    
//    @objc fileprivate func handleTapped(_ sender: Any) {
//        guard let website = performer.website, let delegate = delegate as? URLSelectable else { return }
//        delegate.handleUrlPressed(urlStr: website, title: performer.name, item: self.item, shouldLog: true)
//    }
//}
//
//// MARK: - Prepare UI
//extension HomeFlingCell {
//    fileprivate func prepareUI() {
//        prepareImageView()
//        preparePerformerLabel()
//        prepareDescriptionLabel()
//        prepareDateLabel()
//        // prepareMoreButton()
//    }
//    
//    private func prepareImageView() {
//        performerImageView = UIImageView()
//        if #available(iOS 11.0, *) {
//            performerImageView.layer.cornerRadius = cardView.layer.cornerRadius
//            performerImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        }
//        performerImageView.clipsToBounds = true
//        performerImageView.contentMode = .scaleAspectFill
//        
//        let tapGestureRecognizer = getTapGestureRecognizer()
//        performerImageView.addGestureRecognizer(tapGestureRecognizer)
//        performerImageView.isUserInteractionEnabled = true
//        
//        cardView.addSubview(performerImageView)
//        let height = HomeFlingCell.getImageHeight()
//        _ = performerImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
//    }
//    
//    fileprivate static func getImageHeight() -> CGFloat {
//        let cardWidth = UIScreen.main.bounds.width - 40
//        return 0.5 * cardWidth
//    }
//    
//    private func preparePerformerLabel() {
//        performerLabel = UILabel()
//        performerLabel.font = HomeFlingCell.nameFont
//        performerLabel.numberOfLines = 8
//        
//        let tapGestureRecognizer = getTapGestureRecognizer()
//        performerLabel.addGestureRecognizer(tapGestureRecognizer)
//        performerLabel.isUserInteractionEnabled = true
//        
//        cardView.addSubview(performerLabel)
//        _ = performerLabel.anchor(performerImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 12, leftConstant: HomeFlingCell.nameEdgeOffset, bottomConstant: 0, rightConstant: HomeFlingCell.nameEdgeOffset, widthConstant: 0, heightConstant: 0)
//    }
//    
//    private func prepareDescriptionLabel() {
//        descriptionLabel = UILabel()
//        descriptionLabel.font = HomeFlingCell.descriptionFont
//        descriptionLabel.textColor = UIColor.labelSecondary
//        descriptionLabel.numberOfLines = 3
//        
//        cardView.addSubview(descriptionLabel)
//        _ = descriptionLabel.anchor(performerLabel.bottomAnchor, left: performerLabel.leftAnchor, bottom: nil, right: performerLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//    }
//    
//    private func prepareDateLabel() {
//        dateLabel = UILabel()
//        dateLabel.font = UIFont(name: "HelveticaNeue", size: 14)
//        dateLabel.textColor = UIColor.labelSecondary
//        
//        cardView.addSubview(dateLabel)
//        _ = dateLabel.anchor(nil, left: performerLabel.leftAnchor, bottom: cardView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//    }
//    
//    private func prepareMoreButton() {
//        moreButton = UIButton(type: .custom)
//        moreButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
//        moreButton.setTitleColor(.labelSecondary, for: .normal)
//        moreButton.setTitle("See more Fling ->", for: .normal)
//        
//        cardView.addSubview(moreButton)
//        _ = moreButton.anchor(nil, left: nil, bottom: nil, right: performerLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//        moreButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
//    }
//}
