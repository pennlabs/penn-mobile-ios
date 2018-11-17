//
//  HomeEventCell.swift
//  PennMobile
//
//  Created by Carin Gan on 11/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeEventCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "homeEventCell"
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeEventCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var event: Event!
    
    // MARK: Cell Height
    
    static let nameFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 24)!
    static let nameEdgeOffset: CGFloat = 16
    
    static let locationFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 12)!
    static let clubFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 12)!
    static let dateFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 12)!
    static let descriptionFont: UIFont = UIFont(name: "AvenirNext-Regular", size: 12)!
    
    private static var nameHeightDictionary = [String: CGFloat]()
    private static var descriptionHeightDictionary = [String: CGFloat]()
    private static var dateHeightDictionary = [String: CGFloat]()
    private static var clubHeightDictionary = [String: CGFloat]()
    private static var locationHeightDictionary = [String: CGFloat]()
    
    private static func getLabelHeight(for string: String, of width: CGFloat, with font: UIFont, from dict: [String: CGFloat]) -> CGFloat {
        let labelHeight: CGFloat
        if let height = dict[string] {
            labelHeight = height
        } else {
            labelHeight = string.dynamicHeight(font: font, width: width)
        }
        return labelHeight
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeEventCellItem else { return 0 }
        let imageHeight = getImageHeight()
        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * nameEdgeOffset
        
        // Compute event name height
        let nameHeight = getLabelHeight(for: item.event.name, of: width, with: nameFont, from: nameHeightDictionary)
        nameHeightDictionary[item.event.name] = nameHeight
        
        // Compute event description height
        let descriptionHeight = getLabelHeight(for: item.event.description, of: width, with: descriptionFont, from: descriptionHeightDictionary)
        descriptionHeightDictionary[item.event.description] = descriptionHeight
        
        // Compute event date height
        let dateHeight = getLabelHeight(for: item.event.timeDescription(), of: (width / 2) - 10.0, with: dateFont, from: dateHeightDictionary)
        dateHeightDictionary[item.event.timeDescription()] = dateHeight
        
        // Compute event location height
        let locationHeight = getLabelHeight(for: item.event.location, of: (width / 2) - 10.0, with: locationFont, from: locationHeightDictionary)
        locationHeightDictionary[item.event.location] = locationHeight
        
        // Compute event club name height
        let clubHeight = getLabelHeight(for: item.event.club, of: (width / 2), with: clubFont, from: clubHeightDictionary)
        clubHeightDictionary[item.event.club] = clubHeight

        // Compute overall height
        //let height = imageHeight + HomeViewController.cellSpacing + nameHeight + descriptionHeight + max(dateHeight, locationHeight) + clubHeight
        let height = (width / 2) + HomeViewController.cellSpacing + nameHeight + descriptionHeight + max(dateHeight, locationHeight) + clubHeight
        print(height)
        return height
    }
    
    // MARK: UI Elements
    
    var cardView: UIView! = UIView()
    
    fileprivate var eventImageView: UIImageView!
    fileprivate var eventLabel: UILabel!
    fileprivate var clubLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    //fileprivate var timeLabel: UILabel!
    fileprivate var locationLabel: UILabel!

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
extension HomeEventCell {
    fileprivate func setupCell(with item: HomeEventCellItem) {
        self.event = item.event
        self.eventImageView.image = item.image
        self.eventLabel.text = event.name
        self.clubLabel.text = event.club
        self.descriptionLabel.text = event.description
        self.dateLabel.text = getDateString(for: event)
//        self.timeLabel.text = getTimeString(for: event)
        self.locationLabel.text = event.location
    }
    
    private func getTimeString(for event: Event) -> String {
        let now = Date()
        if event.startTime < now && now < event.endTime && event.startTime.isToday {
            return "Happening now"
        }
        
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "h:mma"
        
        return "\(formatter.string(from: event.startTime)) to \(formatter.string(from: event.endTime))"
    }
    
    private func getDateString(for event: Event) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        
        return "\(formatter.string(from: event.startTime))"
    }
}

// MARK: - Gesture Recognizer
extension HomeEventCell {
    fileprivate func getTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    @objc fileprivate func handleTapped(_ sender: Any) {
        guard let website = event.website, let delegate = delegate as? URLSelectable else { return }
        delegate.handleUrlPressed(website)
    }
}

// MARK: - Prepare UI
extension HomeEventCell {
    fileprivate func prepareUI() {
        prepareImageView()
        prepareDateLabel()
        prepareLocationLabel()
        prepareEventLabel()
        prepareDescriptionLabel()
        prepareClubLabel()
    }
    
    private func prepareImageView() {
        eventImageView = UIImageView()
        if #available(iOS 11.0, *) {
            eventImageView.layer.cornerRadius = cardView.layer.cornerRadius
            eventImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        eventImageView.clipsToBounds = true
        eventImageView.contentMode = .scaleAspectFill
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        eventImageView.addGestureRecognizer(tapGestureRecognizer)
        eventImageView.isUserInteractionEnabled = true
        
        cardView.addSubview(eventImageView)
        let height = HomeEventCell.getImageHeight()
        _ = eventImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    fileprivate static func getImageHeight() -> CGFloat {
        let cardWidth = UIScreen.main.bounds.width - 40
        return 0.5 * cardWidth
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = HomeEventCell.dateFont
        dateLabel.textColor = UIColor.navigationBlue
        
        cardView.addSubview(dateLabel)
        _ = dateLabel.anchor(eventImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 8, leftConstant: 8)
    }
    
    private func prepareLocationLabel() {
        locationLabel = UILabel()
        locationLabel.font = HomeEventCell.locationFont
        locationLabel.textColor = UIColor.navigationBlue
        
        cardView.addSubview(locationLabel)
        _ = locationLabel.anchor(eventImageView.bottomAnchor, left: nil, bottom: nil, right: cardView.rightAnchor, topConstant: 8, rightConstant: 8)
    }
    
    private func prepareEventLabel() {
        eventLabel = UILabel()
        eventLabel.font = HomeEventCell.nameFont
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        eventLabel.addGestureRecognizer(tapGestureRecognizer)
        eventLabel.isUserInteractionEnabled = true
        
        cardView.addSubview(eventLabel)
        _ = eventLabel.anchor(dateLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 8, leftConstant: 8, rightConstant: 8)
    }
    
    private func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.font = HomeEventCell.descriptionFont
        descriptionLabel.textColor = UIColor.warmGrey
        descriptionLabel.numberOfLines = 3
        
        cardView.addSubview(descriptionLabel)
        _ = descriptionLabel.anchor(eventLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 8, leftConstant: 8, rightConstant: 8)
    }
    
    private func prepareClubLabel() {
        clubLabel = UILabel()
        clubLabel.font = HomeEventCell.clubFont
        clubLabel.textColor = UIColor.navigationBlue
        
        cardView.addSubview(clubLabel)
        _ = clubLabel.anchor(descriptionLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8)
    }
}

