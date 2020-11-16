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
    static let cellHeight: CGFloat = 84
    
    var calendarEvent: CalendarEvent! {
        didSet {
            setupCell(with: calendarEvent)
        }
    }
    
    // MARK: UI Elements
    fileprivate var eventLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var pennCrest: UIImageView!
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        backgroundColor = .clear
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
        eventLabel = getEventLabel()
        dateLabel = getDateLabel()
        pennCrest = getPennCrest()
        let centeredView = UIView()
        
        addSubview(centeredView)
        centeredView.addSubview(eventLabel)
        centeredView.addSubview(dateLabel)
        addSubview(pennCrest)
        
        
        pennCrest.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(pad)
            make.centerY.equalTo(self)
            make.height.equalTo(54)
            make.width.equalTo(46)
        }
        
        centeredView.snp.makeConstraints { (make) in
            make.leading.equalTo(pennCrest.snp.trailing).offset(pad)
            make.trailing.equalTo(self).offset(-pad)
            make.centerY.equalTo(pennCrest)
        }
        
        eventLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(centeredView)
            make.trailing.equalTo(centeredView)
            make.top.equalTo(centeredView)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(centeredView)
            make.trailing.equalTo(centeredView)
            make.bottom.equalTo(centeredView)
            make.top.equalTo(eventLabel.snp.bottom).offset(3)
        }
    }
    
    fileprivate func getDateLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryInformationFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }
    
    fileprivate func getEventLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textAlignment = .left
        label.textColor = .labelPrimary
        label.numberOfLines = 2
        return label
    }
    
    fileprivate func getPennCrest() -> UIImageView {
        let image = UIImageView()
        image.image = UIImage(named: "upenn")
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .clear
        image.layer.cornerRadius = 5
        return image
    }
}
