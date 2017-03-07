//
//  AgendaCell.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

struct Time: Hashable {
    let hour: Int
    let minutes: Int
    let isAm: Bool
    
    func rawMinutes() -> Int {
        var total = hour * 60 + minutes
        if !isAm && hour != 12 {
            total += 12*60
        }
        return total
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minutes == rhs.minutes && lhs.isAm == rhs.isAm
    }
    
    var hashValue: Int {
        get {
            var hash = hour.hashValue
            hash += (55*hash + minutes.hashValue)
            hash += (55*hash + isAm.hashValue)
            return hash
        }
    }
}

struct Event: Hashable {
    let name: String
    let location: String?
    let startTime: Time
    let endTime: Time
    
    func isConflicting(with event: Event) -> Bool {
        return event.occurs(at: startTime) || self.occurs(at: event.startTime)
    }
    
    func occurs(at time: Time) -> Bool {
        let eventStartTime = startTime.rawMinutes()
        var eventEndTime = endTime.rawMinutes()
        
        if eventEndTime < eventStartTime {
            eventEndTime += 24*60
        }
        
        let rawTime = time.rawMinutes()
        
        return rawTime >= eventStartTime && rawTime < eventEndTime
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.name == rhs.name && lhs.location == rhs.location && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
    
    var hashValue: Int {
        get {
            var hash = name.hashValue
            print(name.hashValue)
            if let location = location {
                print(location)
                print(location.hashValue)
                hash += (3*hash + location.hashValue)
            }
            hash += (3*hash + startTime.hashValue)
            hash += (3*hash + endTime.hashValue)
            return hash
        }
    }
    
    static var conflictingEventsDictionary: [Event: [Event]] = [Event: [Event]]()
}

protocol AgendaDelegate {
    func getAnnouncement() -> String?
}

class AgendaCell: UITableViewCell, ScheduleTableDelegate {
    
    var mainAnnouncement = UILabel()
    
    let events: [Event] = {
        let event1 = Event(name: "LGST101", location: "SHDH 211", startTime: Time(hour: 8, minutes: 0, isAm: true), endTime: Time(hour: 9, minutes: 0, isAm: true))
        
        let event2 = Event(name: "MEAM101", location: "TOWN 101", startTime: Time(hour: 9, minutes: 0, isAm: true), endTime: Time(hour: 11, minutes: 0, isAm: true))
        
        let event3 = Event(name: "FNAR264", location: "FSHR 203", startTime: Time(hour: 11, minutes: 0, isAm: true), endTime: Time(hour: 12, minutes: 0, isAm: false))
        
        //let event4 = Event(name: "MATH240", location: "HUNT 250", startTime: Time(hour: 11, minutes: 0, isAm: true), endTime: Time(hour: 3, minutes: 0, isAm: false))
        
        let event4 = Event(name: "GSWS101", location: "WILL 027", startTime: Time(hour: 1, minutes: 0, isAm: false), endTime: Time(hour: 2, minutes: 0, isAm: false))
        
        let events = [event1, event2, event3, event4]
        
        return events.sorted { (event1, event2) -> Bool in
            let raw1 = event1.startTime.rawMinutes()
            let raw2 = event2.startTime.rawMinutes()
            
            //sort by latest event first
            if raw1 == raw2 {
                return event1.endTime.rawMinutes() > event2.endTime.rawMinutes()
            }
            
            return raw1 < raw2
        }
    }()
    
    private static let HeaderHeight: CGFloat = 50
    private static let AnnouncementHeight: CGFloat = 35
    
    var announcement: String? {
        get {
            return delegate?.getAnnouncement()
        }
    }
    
    private var showAnnouncement: Bool = false
    
    public var delegate: AgendaDelegate? {
        didSet {
            announcementLabel.text = announcement
            showAnnouncement = announcement != nil
            setupCell()
        }
    }
    
    private let header: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        label.text = "Your Monday schedule looks like"
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var body: ScheduleTable = {
        let st = ScheduleTable()
        st.delegate = self
        return st
    }()
    
    private let announcementLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(r: 63, g: 81, b: 181)
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textAlignment = .center
        return label
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        selectionStyle = .none
    }
    
    private func setupCell() {
        //remove all subviews
        let views = subviews
        
        for view in views {
            view.removeFromSuperview()
        }
        
        addSubview(header)
        addSubview(body)
        
        _ = header.anchor(topAnchor, left: leftAnchor, bottom: topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: -AgendaCell.HeaderHeight, rightConstant: 0, widthConstant: 0, heightConstant: AgendaCell.HeaderHeight)
        
        var tempTopAnchor = header.bottomAnchor
        
        if showAnnouncement {
            addSubview(announcementLabel)
            
            _ = announcementLabel.anchor(tempTopAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: AgendaCell.AnnouncementHeight)
            
            tempTopAnchor = announcementLabel.bottomAnchor
        }
        
        _ = body.anchorToTop(tempTopAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
    }
    
    func getEvents() -> [Event] {
        return events
    }
}

protocol ScheduleTableDelegate {
    func getEvents() -> [Event]
}

class ScheduleTable: UIView {
    
    let heightForHour: CGFloat = 50
    let leftOffset: CGFloat = 60
    let rightOffset: CGFloat = 24
    
    let padding: CGFloat = 4.0
    
    private lazy var collectionView: UICollectionView = {
        let layout = ScheduleLayout()
        layout.delegate = self
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.allowsSelection = false
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    internal var events: [Event] {
        get {
            return delegate.getEvents()
        }
    }
    
    let scheduleCell = "scheduleCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(r: 248, g: 248, b: 248)
        
        addSubview(collectionView)
        
        collectionView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 20, leftConstant: leftOffset, bottomConstant: 8, rightConstant: rightOffset)
        
        collectionView.register(ScheduleEventCell.self, forCellWithReuseIdentifier: scheduleCell)
    }
    
    public var delegate: ScheduleTableDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ScheduleTable: UICollectionViewDelegate, UICollectionViewDataSource {
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scheduleCell, for: indexPath) as! ScheduleEventCell
        cell.event = events[indexPath.item]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension ScheduleTable: ScheduleLayoutDelegate {
    func getPadding() -> CGFloat {
        return padding
    }
    
    func getHeightForHour() -> CGFloat {
        return heightForHour
    }
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, heightForHour: CGFloat) -> CGFloat {
        let event = events[indexPath.item]
        let startTime = event.startTime
        let endTime = event.endTime
        
        return heightForHour * CGFloat(endTime.rawMinutes() - startTime.rawMinutes()) / 60.0
    }
    
    func collectionView(collectionView: UICollectionView, widthForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let conflictingEvents = maxConflictingEvents(for: events[indexPath.item])
        
        if conflictingEvents.isEmpty { return 0 }
        
        var count = conflictingEvents.count
        let minCellWidth = cellWidth(numberOfConflictingEvents: count, width: width)
        
        if indexPath.item == 0 || count == 1 || conflictingEvents[0] == events[indexPath.item] {
            return minCellWidth
        }
        
        var remainingWidth = width
        
        for conflictingEvent in conflictingEvents {
            let index = events.index { (event) -> Bool in
                event == conflictingEvent
            }
            
            if let index = index, index < indexPath.item {
                let width = self.collectionView(collectionView: collectionView, widthForCellAtIndexPath: IndexPath(item: index, section: 0), width: width)
                
                remainingWidth -= width
                count -= 1
            }
        }
        
        var calculatedWidth = cellWidth(numberOfConflictingEvents: count, width: remainingWidth)
        
        if calculatedWidth > minCellWidth {
            for conflictingEvent in conflictingEvents {
                let index = events.index { (event) -> Bool in
                    event == conflictingEvent
                }
                
                if let index = index, index < indexPath.item {
                    let prevXOffset = self.collectionView(collectionView: collectionView, xOffsetForCellAtIndexPath: IndexPath(item: index, section: 0) ,  width: width)
                    
                    if prevXOffset < calculatedWidth && prevXOffset > 0 {
                        calculatedWidth = prevXOffset
                    }
                }
            }
        }
        
        return calculatedWidth
    }
    
    private func cellWidth(numberOfConflictingEvents: Int, width: CGFloat) -> CGFloat {
        return width/CGFloat(numberOfConflictingEvents)
    }
    
    func collectionView(collectionView: UICollectionView, xOffsetForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        if indexPath.item == 0 { return 0.0 }
        
        let event = events[indexPath.item]
        
        let conflictingEvents = maxConflictingEvents(for: event)
        
        let numberOfConflicts = conflictingEvents.count
        if numberOfConflicts == 1 { return 0.0 }

        var validXOffsets: [CGFloat] = [CGFloat]()
        
        let cellWidth = self.collectionView(collectionView: collectionView, widthForCellAtIndexPath: indexPath, width: width)
        
        var nextOffset: CGFloat = 0.0
        while nextOffset < width && nextOffset != width {
            validXOffsets.append(nextOffset)
            nextOffset += cellWidth > width/2 ? width - cellWidth : cellWidth
        }
        
        for conflictingEvent in conflictingEvents {
            
            let index = events.index { (event) -> Bool in
                event == conflictingEvent
            }
            
            if let index = index, index < indexPath.item {
                
                let index = IndexPath(item: index, section: 0)
                
                let prevXOffset = self.collectionView(collectionView: collectionView, xOffsetForCellAtIndexPath: index, width: width)
                
                if let xIndex = validXOffsets.index(of: prevXOffset) {
                    validXOffsets.remove(at: xIndex)
                }
            }
        }
        
        return validXOffsets.first!
    }
    
    func collectionView(collectionView: UICollectionView, yOffsetForCellAtIndexPath indexPath: IndexPath, heightForHour: CGFloat) -> CGFloat {
        let event = events[indexPath.item]
        return heightForHour * CGFloat(event.startTime.rawMinutes() - minimumStartTime().rawMinutes()) / 60.0
    }
    
    //returns all conflicting events, including itself
    private func getConflictingEvents(for event: Event) -> [Event] {
        var conflictingEvents = [Event]()
        
        for thisEvent in events {
            if thisEvent.isConflicting(with: event) {
                conflictingEvents.append(thisEvent)
            }
        }
        return conflictingEvents
    }
    
    //returns all conflicting events, including the event itself, when most conflicting events occur
    private func maxConflictingEvents(for event: Event) -> [Event] {
        var maxEvents: [Event] = []
        
        let conflictingEvents = getConflictingEvents(for: event)
        
        for event in conflictingEvents {
            let startTime = event.startTime
            var tempEvents: [Event] = []
            
            for otherEvent in conflictingEvents {
                if otherEvent.occurs(at: startTime) {
                    tempEvents.append(otherEvent)
                }
            }
            
            if maxEvents.count < tempEvents.count {
                maxEvents = tempEvents
            }
            
        }
        
        //Event.conflictingEventsDictionary[event] = maxEvents

        return maxEvents
    }
    
    private func maximumNumberConflictingEvents(for event: Event) -> Int {
        return maxConflictingEvents(for: event).count
    }
    
    //returns the minimum startTime
    private func minimumStartTime() -> Time {
        var minStartTime = Time(hour: 11, minutes: 59, isAm: false)
        for event in events {
            let eventStartTime = event.startTime
            if eventStartTime.rawMinutes() < minStartTime.rawMinutes() {
                minStartTime = eventStartTime
            }
        }
        return minStartTime
    }
}

class ScheduleEventCell: UICollectionViewCell {
    
    public var event: Event! {
        didSet {
            var str = event.name
            if let location = event.location {
                str += "\n\(location)"
            }
            
            let attributedString = NSMutableAttributedString(string: str)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            label.attributedText = attributedString;
        }
    }
    
    private var color: UIColor = UIColor(r: 73, g: 144, b: 226) {
        didSet {
            backgroundColor = color
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.textColor = UIColor(r: 248, g: 248, b: 248)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = color
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        addSubview(label)
        
        _ = label.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? ScheduleLayoutAttributes {
            color = attributes.color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
