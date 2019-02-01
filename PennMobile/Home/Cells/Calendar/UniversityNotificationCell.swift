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
    let eventStore : EKEventStore = EKEventStore()
    var added: Bool = false
    var event: EKEvent!
    
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
    
    // MARK: - Add event to calendar
    func addEventToCalendar(title: String, startDate: Date, endDate: Date, notes: String?, location: String) {
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            granted, error in
            if (granted) && (error == nil) {
                //let event: EKEvent = EKEvent(eventStore: self.eventStore)
                self.event = EKEvent(eventStore: self.eventStore)
                self.event.title = title
                self.event.startDate = startDate
                self.event.endDate = endDate
                self.event.notes = notes
                self.event.location = location
                self.event.calendar = self.eventStore.defaultCalendarForNewEvents
                print(self.event.eventIdentifier)
                do {
                    try self.eventStore.save(self.event, span: EKSpan.thisEvent)
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
        pennCrest = getPennCrest()
        //addToCalendarButton = getAddToCalendarButton()
        
        addSubview(eventLabel)
        addSubview(dateLabel)
        addSubview(pennCrest)
        //addSubview(addToCalendarButton)
        
        _ = eventLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: padding, leftConstant: 125, rightConstant: padding)
        _ = dateLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 60, leftConstant: 125, bottomConstant: 13, rightConstant: padding)
        _ = pennCrest.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 13, leftConstant: 30, widthConstant: 83, heightConstant: 83)
        
//        _ = addToCalendarButton.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 60, leftConstant: 10, bottomConstant: padding, rightConstant: padding)
        
    }
    
    fileprivate func getDateLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        //label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .center
        return label
    }
    
    fileprivate func getEventLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 20)
        label.textAlignment = .center
        label.textColor = UIColor.primaryTitleGrey
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
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

// MARK: - Add to Calendar feature not finished and not in use (ignore code below)
    
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
        
        if (added) {
            //sender.setImage(UIImage(named:"Checked.png"), for: [])
            
            do {
                try eventStore.remove(event, span: EKSpan.thisEvent)
                print("event removed")
            } catch {
                print("couldn't remove")
            }
            sender.setTitle("Add To Calendar", for: [])
            added = false;
        }
        else {
            addEventToCalendar(title: calendarEvent.name, startDate: calendarEvent.start, endDate: calendarEvent.end, notes: "", location: "")
            sender.setTitle("Remove From Calendar", for: [])
            added = true
            //sender.setImage(UIImage(named:"Checked.png"), for: [])
        }
    }
}
