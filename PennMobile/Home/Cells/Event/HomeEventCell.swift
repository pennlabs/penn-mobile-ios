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
    
    fileprivate let padding = UIView.padding
    
    
    // MARK: - Compute Cell Height
    // Declare fonts statically, so that the height can be computed
    static let nameFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 24)!
    static let nameEdgeOffset: CGFloat = padding
    static let locationFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 14)!
    static let clubFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 14)!
    static let dateFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 14)!
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
        let height = (padding * 5) + imageHeight + nameHeight + descriptionHeight + max(dateHeight, locationHeight) + clubHeight
        return height
    }
    
    // MARK: Declare UI Elements
    var cardView: UIView! = UIView()
    fileprivate var eventImageView: UIImageView!
    fileprivate var eventLabel: UILabel!
    fileprivate var clubLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var dateLabel: UILabel!
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

// MARK: - Setup Home Cell Item
extension HomeEventCell {
    fileprivate func setupCell(with item: HomeEventCellItem) {
        self.event = item.event
        self.eventImageView.image = item.image
        self.eventLabel.text = event.name
        self.clubLabel.text = event.club
        self.descriptionLabel.text = event.description
        self.dateLabel.text = event.timeDescription()
        self.locationLabel.text = event.location
    }
    
    /*private func getTimeString(for event: Event) -> String {
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
        
        return "This is a long date because there is stuff in front etc... \(formatter.string(from: event.startTime))"
    }*/
}

// MARK: - Tap Gesture Recognizers
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

// MARK: - Initialize UI
extension HomeEventCell {
    fileprivate func prepareUI() {
        prepareImageView()
        prepareLabels()
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
        _ = eventImageView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, heightConstant: height)
    }
    
    fileprivate static func getImageHeight() -> CGFloat {
        let cardWidth = UIScreen.main.bounds.width - 40
        return 0.5 * cardWidth
    }
    
    private func prepareLabels() {
        // Initialize labels
        dateLabel = getDateLabel()
        locationLabel = getLocationLabel()
        eventLabel = getEventLabel()
        descriptionLabel = getDescriptionLabel()
        clubLabel = getClubLabel()
        
        // Add labels to subview
        cardView.addSubview(dateLabel)
        cardView.addSubview(locationLabel)
        cardView.addSubview(eventLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(clubLabel)
        
        _ = dateLabel.anchor(eventImageView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.centerXAnchor, topConstant: padding, leftConstant: padding, rightConstant: 10)
        
        _ = locationLabel.anchor(eventImageView.bottomAnchor, left: cardView.centerXAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: padding, leftConstant: 10, rightConstant: padding)
        
        // Custom constraints for eventLabel, to constrain itself to the max(dateLabel, locationLabel)
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        eventLabel.topAnchor.constraint(greaterThanOrEqualTo: dateLabel.bottomAnchor, constant: padding / 2).isActive = true
        eventLabel.topAnchor.constraint(greaterThanOrEqualTo: locationLabel.bottomAnchor, constant: padding / 2).isActive = true
        let lowPriorityEventAnchor = eventLabel.topAnchor.constraint(equalTo: topAnchor)
        lowPriorityEventAnchor.priority = 500 // less than the dateLabel, locationLabel priorities
        lowPriorityEventAnchor.isActive = true
        eventLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: padding).isActive = true
        eventLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -padding).isActive = true
        
        //_ = eventLabel.anchor(dateLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: padding / 2, leftConstant: padding, rightConstant: padding)
        
        _ = descriptionLabel.anchor(eventLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: padding / 2, leftConstant: padding, rightConstant: padding)
        
        _ = clubLabel.anchor(descriptionLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: nil, topConstant: padding / 2, leftConstant: padding)
    }

    fileprivate func getDateLabel() -> UILabel {
        let label = UILabel()
        label.font = HomeEventCell.dateFont
        label.textColor = UIColor.navigationBlue
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    fileprivate func getLocationLabel() -> UILabel {
        let label = UILabel()
        label.font = HomeEventCell.locationFont
        label.textColor = UIColor.navigationBlue
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }
    
    fileprivate func getEventLabel() -> UILabel {
        let label = UILabel()
        label.font = HomeEventCell.nameFont
        label.textColor = UIColor.primaryTitleGrey
        return label
    }
    
    fileprivate func getDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = HomeEventCell.descriptionFont
        label.textColor = UIColor.warmGrey
        // Change this to limit the number of description lines
        label.numberOfLines = 0
        return label
    }
    
    fileprivate func getClubLabel() -> UILabel {
        let label = UILabel()
        label.font = HomeEventCell.clubFont
        label.textColor = UIColor.lightGray
        return label
    }
}

