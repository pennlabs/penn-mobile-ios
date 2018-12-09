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
    static let cellHeight: CGFloat = 120
    
    var calendarEvent: CalendarEvent! {
        didSet {
            setupCell(with: calendarEvent)
        }
    }
    
    // MARK: Declare UI Elements
    fileprivate var eventLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var addToCalendarButton: UIButton!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Add event to calendar
    func addEventToCalendar(title: String, startDate: Date, endDate: Date, notes: String?, location: String) {
        
        let eventStore : EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            granted, error in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error  \(String(describing: error))")
                let event: EKEvent = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = notes
                event.location = location
                event.calendar = eventStore.defaultCalendarForNewEvents
                print(event.eventIdentifier)
                do {
                    try eventStore.save(event, span: EKSpan.thisEvent)
                    print("event saved")
                } catch {
                }
            }
        })
    }
}

// MARK: - Set up cell

extension UniversityNotificationCell {
    fileprivate func setupCell(with calendarEvent: CalendarEvent) {
        eventLabel.text = calendarEvent.name
        dateLabel.text = calendarEvent.getDateString()
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
        addToCalendarButton = getAddToCalendarButton()
        
        addSubview(eventLabel)
        addSubview(dateLabel)
        addSubview(addToCalendarButton)
        
        _ = eventLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: padding, leftConstant: padding, rightConstant: 10)
        _ = dateLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: centerXAnchor, topConstant: 60, leftConstant: padding, bottomConstant: padding, rightConstant: 10)
        _ = addToCalendarButton.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 60, leftConstant: 10, bottomConstant: padding, rightConstant: padding)
        
    }
    
    fileprivate func getDateLabel() -> UILabel {
        let label = UILabel()
        label.font = HomeEventCell.dateFont
        label.textColor = UIColor.navigationBlue
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    fileprivate func getEventLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = UIColor.primaryTitleGrey
        return label
    }
    
    fileprivate func getAddToCalendarButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.navigationBlue
        button.titleLabel?.font =  HomeEventCell.clubFont
        button.setTitle("Add To Calendar", for: [])
        button.setTitleColor(UIColor.white, for: [])
        
        button.layer.cornerRadius = 35.0/2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        button.addTarget(self, action: #selector(didTapAddToCalendarButton), for: .touchUpInside)
        return button
    }
    
    @objc func didTapAddToCalendarButton(sender: UIButton!) {
        addEventToCalendar(title: calendarEvent.name, startDate: calendarEvent.start, endDate: calendarEvent.end, notes: "", location: "")
    }
}
