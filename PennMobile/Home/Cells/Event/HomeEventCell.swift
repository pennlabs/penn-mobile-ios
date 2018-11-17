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
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeEventCellItem else { return 0 }
        let imageHeight = getImageHeight()
        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * nameEdgeOffset
        
        // Compute event name height
        let nameHeight: CGFloat
        if let height = nameHeightDictionary[item.event.name] {
            nameHeight = height
        } else {
            nameHeight = item.event.name.dynamicHeight(font: nameFont, width: width)
            nameHeightDictionary[item.event.name] = nameHeight
        }
        
        // Compute event description height
        let descriptionHeight: CGFloat
        if let height = descriptionHeightDictionary[item.event.description] {
            descriptionHeight = height
        } else {
            descriptionHeight = item.event.description.dynamicHeight(font: descriptionFont, width: width)
            descriptionHeightDictionary[item.event.description] = descriptionHeight
        }
        
        // Compute event duration/location height
        let durationLocationHeight: CGFloat
        if let height = descriptionHeightDictionary[item.event.club] {
            durationLocationHeight = height
        } else {
            durationLocationHeight = item.event.club.dynamicHeight(font: clubFont, width: width)
            descriptionHeightDictionary[item.event.description] = descriptionHeight
        }
        
        let height = imageHeight + HomeViewController.cellSpacing + nameHeight + descriptionHeight + 60
        return height
    }
    
    // MARK: UI Elements
    
    var cardView: UIView! = UIView()
    
    fileprivate var eventImageView: UIImageView!
    fileprivate var eventLabel: UILabel!
    fileprivate var clubLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var timeLabel: UILabel!
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
        self.timeLabel.text = getTimeString(for: event)
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
        prepareEventLabel()
        prepareClubLabel()
        prepareDescriptionLabel()
        prepareDateLabel()
        prepareTimeLabel()
        prepareLocationLabel()
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
    
    private func prepareEventLabel() {
        eventLabel = UILabel()
        eventLabel.font = HomeEventCell.nameFont
        
        let tapGestureRecognizer = getTapGestureRecognizer()
        eventLabel.addGestureRecognizer(tapGestureRecognizer)
        eventLabel.isUserInteractionEnabled = true
        
        cardView.addSubview(eventLabel)
        _ = eventLabel.anchor(eventImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 12, leftConstant: HomeEventCell.nameEdgeOffset, bottomConstant: 0, rightConstant: HomeEventCell.nameEdgeOffset, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareClubLabel() {
        clubLabel = UILabel()
        clubLabel.font = HomeEventCell.descriptionFont
        clubLabel.textColor = UIColor.black
        
        cardView.addSubview(clubLabel)
        _ = clubLabel.anchor(eventLabel.bottomAnchor, left: eventLabel.leftAnchor, bottom: nil, right: eventLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        descriptionLabel.textColor = UIColor.warmGrey
        descriptionLabel.numberOfLines = 3
        
        cardView.addSubview(descriptionLabel)
        _ = descriptionLabel.anchor(clubLabel.bottomAnchor, left: clubLabel.leftAnchor, bottom: nil, right: clubLabel.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        dateLabel.textColor = UIColor.warmGrey
        
        cardView.addSubview(dateLabel)
        _ = dateLabel.anchor(descriptionLabel.bottomAnchor, left: descriptionLabel.leftAnchor, bottom: nil, right: descriptionLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareTimeLabel() {
        timeLabel = UILabel()
        timeLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        timeLabel.textColor = UIColor.warmGrey

        cardView.addSubview(timeLabel)
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: dateLabel.leftAnchor, bottom: nil, right: dateLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    private func prepareLocationLabel() {
        locationLabel = UILabel()
        locationLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        locationLabel.textColor = UIColor.warmGrey

        cardView.addSubview(locationLabel)
//        _ = locationLabel.anchor(nil, left: eventLabel.leftAnchor, bottom: cardView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = locationLabel.anchor(timeLabel.bottomAnchor, left: timeLabel.leftAnchor, bottom: cardView.bottomAnchor, right: timeLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}

