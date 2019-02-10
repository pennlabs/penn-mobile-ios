//
//  UniversityNotificationCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 12/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import EventKit

class UniversityNotificationCell: UITableViewCell {
    
    static let identifier = "universityNotificationCell"
    static let cellHeight: CGFloat = 110
    
    var calendarEvent: CalendarEvent! {
        didSet {
            setupCell(with: calendarEvent)
        }
    }
    
    // MARK: Declare UI Elements
    fileprivate var eventLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var pennCrest: UIImageView!
    fileprivate var addToCalendarButton: UIButton!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Set up cell
extension UniversityNotificationCell {
    fileprivate func setupCell(with calendarEvent: CalendarEvent) {
        eventLabel.text = calendarEvent.name
        dateLabel.text = calendarEvent.getDateString(fullLength: false)
    }
}

// MARK: - Prepare UI
extension UniversityNotificationCell {
    fileprivate func prepareUI() {
        prepareLabels()
    }
    
    fileprivate func prepareLabels() {
        let padding = UIView.padding
        
        eventLabel = getEventLabel()
        dateLabel = getDateLabel()
        pennCrest = getPennCrest()
        
        addSubview(eventLabel)
        addSubview(dateLabel)
        addSubview(pennCrest)
        
        _ = eventLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: padding, leftConstant: 120, rightConstant: padding, heightConstant: 50)
        _ = dateLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 50, leftConstant: 120, bottomConstant: 25, rightConstant: padding)
        _ = pennCrest.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 13, leftConstant: 25, widthConstant: 83, heightConstant: 83)
        
    }
    
    fileprivate func getDateLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .center
        label.numberOfLines = 1
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getEventLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 18)
        label.textAlignment = .center
        label.textColor = UIColor.primaryTitleGrey
        label.numberOfLines = 2
        return label
    }
    
    fileprivate func getPennCrest() -> UIImageView {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 83).isActive = true
        image.heightAnchor.constraint(equalToConstant: 83).isActive = true
        image.image = UIImage(named: "upenn")
        return image
    }
}
