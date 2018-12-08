//
//  HomeCalendarCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import EventKit

final class HomeCalendarCell: UITableViewCell, HomeCellConformable {
    
    var eventStore : EKEventStore = EKEventStore()
    
    static var identifier: String = "calendarCell"
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeCalendarCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var delegate: ModularTableViewCellDelegate!
    var event: CalendarEvent!
    
    fileprivate let padding = UIView.padding
    
    // MARK: - Compute Cell Height
    // Declare fonts statically, so that the height can be computed
    static let nameFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 24)!
    static let nameEdgeOffset: CGFloat = padding
    static let dateFont: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 14)!
    
    private static var nameHeightDictionary = [String: CGFloat]()
    private static var dateHeightDictionary = [String: CGFloat]()
    
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
        guard let item = item as? HomeCalendarCellItem else { return 0 }
        let width: CGFloat = UIScreen.main.bounds.width - 2 * 20 - 2 * nameEdgeOffset
        
        // Compute event name height
        let nameHeight = getLabelHeight(for: item.event.name, of: width, with: nameFont, from: nameHeightDictionary)
        nameHeightDictionary[item.event.name] = nameHeight
        
        // Compute event date height
        let dateHeight = getLabelHeight(for: item.event.getDateString(), of: (width / 2) - 10.0, with: dateFont, from: dateHeightDictionary)
        dateHeightDictionary[item.event.getDateString()] = dateHeight
        
        // Compute overall height
        let height = (padding * 5) + nameHeight + dateHeight
        return height
    }
    
    // MARK: Declare UI Elements
    var cardView: UIView! = UIView()
    fileprivate var eventLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var addToCalendarButton: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
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
                print("granted \(granted)")
                print("error  \(String(describing: error))")
                self.eventStore = EKEventStore()
                let event: EKEvent = EKEvent(eventStore: self.eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = notes
                event.location = location
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                do {
                    try self.eventStore.save(event, span: EKSpan.thisEvent)
                    print("event saved")
                } catch {
                }
            }
        })
    }
}

// MARK: - Setup Home Cell Item
extension HomeCalendarCell {
    fileprivate func setupCell(with item: HomeCalendarCellItem) {
        self.event = item.event
        //self.event = CalendarEvent.getDefaultCalendarEvent()
        self.eventLabel.text = event.name
        self.dateLabel.text = event.getDateString()
    }
}

// MARK: - Prepare UI
extension HomeCalendarCell {
    fileprivate func prepareUI() {
        prepareLabels()
    }
    
    private func prepareLabels() {
        // Initialize labels
        dateLabel = getDateLabel()
        eventLabel = getEventLabel()
        addToCalendarButton = getAddToCalendarButton()
        
        // Add labels to subview
        cardView.addSubview(dateLabel)
        cardView.addSubview(eventLabel)
        cardView.addSubview(addToCalendarButton)
        
        _ = eventLabel.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: nil, topConstant: padding, leftConstant: padding, rightConstant: 10)
        _ = dateLabel.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.centerXAnchor, topConstant: 60, leftConstant: padding, bottomConstant: padding, rightConstant: 10)
        _ = addToCalendarButton.anchor(cardView.topAnchor, left: nil, bottom: nil, right: cardView.rightAnchor, topConstant: 60, leftConstant: 10, bottomConstant: padding, rightConstant: padding)
        
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
        label.font = HomeEventCell.nameFont
        label.textColor = UIColor.primaryTitleGrey
        return label
    }
    
    fileprivate func getAddToCalendarButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.navigationBlue
        button.titleLabel?.font =  HomeEventCell.clubFont
        button.setTitle("Add To Calendar", for: [])
        button.setTitleColor(UIColor.white, for: [])
        
        button.layer.cornerRadius = 40.0/2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        button.addTarget(self, action: #selector(didTapAddToCalendarButton), for: .touchUpInside)
        return button
    }
    
    @objc func didTapAddToCalendarButton(sender: UIButton!) {
        addEventToCalendar(title: event.name, startDate: event.start, endDate: event.end, notes: "", location: "")
    }

}
