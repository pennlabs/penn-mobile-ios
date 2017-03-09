//
//  Schedule.swift
//  PennMobile
//
//  Created by Josh Doman on 3/8/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol ScheduleTableDelegate {
    func getEvents() -> [Event]
    func getEmptyMessage() -> String
}

class ScheduleTable: UIView {
    
    static let heightForHour: CGFloat = 50
    let leftOffset: CGFloat = 70
    let rightOffset: CGFloat = 24
    static let topOffset: CGFloat = 16
    static let bottomOffset: CGFloat = 30
    
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
    
    private let emptyView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        return label
    }()
    
    internal var events: [Event] {
        get {
            return delegate.getEvents()
        }
    }
    
    internal var times: [Time]!
    
    internal let scheduleCell = "scheduleCell"
    internal let timeCell = "timeCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(r: 248, g: 248, b: 248)
        
        addSubview(emptyView)
        
        emptyView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 80, bottomConstant: 0, rightConstant: 80)
        
        addSubview(collectionView)
        
        collectionView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: ScheduleTable.topOffset, leftConstant: 0, bottomConstant: 0, rightConstant: rightOffset)
        
        collectionView.register(ScheduleEventCell.self, forCellWithReuseIdentifier: scheduleCell)
        collectionView.register(TimeCell.self, forCellWithReuseIdentifier: timeCell)
        
        
    }
    
    public var delegate: ScheduleTableDelegate! {
        didSet {
            loadTimes()
            emptyView.isHidden = !events.isEmpty
            emptyView.text = delegate.getEmptyMessage()
        }
    }
    
    private func loadTimes() {
        var tempTimes = [Time]()
        for event in events {
            let startTime = event.startTime
            if !tempTimes.contains(startTime) {
                tempTimes.append(startTime)
            }
            
            let endTime = event.endTime
            if !tempTimes.contains(endTime) {
                tempTimes.append(endTime)
            }
        }
        
        tempTimes.sort { (time1, time2) -> Bool in
            return time1.rawMinutes() < time2.rawMinutes()
        }
        
        times = tempTimes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func calculateHeightForEvents(for events: [Event]) -> CGFloat {
        if events.isEmpty {
            return 80.0
        }
        
        let minStartTime = minimumStartTime(for: events)
        var maxEndTime = Time(hour: 12, minutes: 0, isAm: true)
        for event in events {
            let eventEndTime = event.endTime
            if eventEndTime.rawMinutes() > maxEndTime.rawMinutes() {
                maxEndTime = eventEndTime
            }
        }
        
        return topOffset +
            heightForHour * CGFloat(maxEndTime.rawMinutes() - minStartTime.rawMinutes()) / 60.0
    }
    
    public func reloadData() {
        collectionView.reloadData()
        loadTimes()
        
        emptyView.isHidden = !events.isEmpty
    }
    
}

extension ScheduleTable: UICollectionViewDelegate, UICollectionViewDataSource {
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return times.count
        } else {
            return events.count
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timeCell, for: indexPath) as! TimeCell
            cell.time = times[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scheduleCell, for: indexPath) as! ScheduleEventCell
            cell.event = events[indexPath.item]
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
}

extension ScheduleTable: ScheduleLayoutDelegate {
    func getLeftOffset() -> CGFloat {
        return leftOffset
    }
    
    func getPadding() -> CGFloat {
        return padding
    }
    
    func getHeightForHour() -> CGFloat {
        return ScheduleTable.heightForHour
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
                let width = self.collectionView(collectionView: collectionView, widthForCellAtIndexPath: IndexPath(item: index, section: 1), width: width)
                
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
                    let prevXOffset = self.collectionView(collectionView: collectionView, xOffsetForCellAtIndexPath: IndexPath(item: index, section: 1) ,  width: width)
                    
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
                
                let index = IndexPath(item: index, section: 1)
                
                let prevXOffset = self.collectionView(collectionView: collectionView, xOffsetForCellAtIndexPath: index, width: width)
                
                if let xIndex = validXOffsets.index(of: prevXOffset) {
                    validXOffsets.remove(at: xIndex)
                }
            }
        }
        
        return validXOffsets.first!
    }
    
    func collectionView(collectionView: UICollectionView, yOffsetForCellAtIndexPath indexPath: IndexPath, heightForHour: CGFloat) -> CGFloat {
        if indexPath.section == 0 {
            return getYOffsetForTime(for: times[indexPath.item], heightForHour: heightForHour)
        }
        
        let event = events[indexPath.item]
        return getYOffsetForTime(for: event.startTime, heightForHour: heightForHour)
    }
    
    private func getYOffsetForTime(for time: Time, heightForHour: CGFloat) -> CGFloat {
        let minStartTime = ScheduleTable.minimumStartTime(for: events)
        return heightForHour * CGFloat(time.rawMinutes() - minStartTime.rawMinutes()) / 60.0
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
        
        return maxEvents
    }
    
    private func maximumNumberConflictingEvents(for event: Event) -> Int {
        return maxConflictingEvents(for: event).count
    }
    
    //returns the minimum startTime
    internal static func minimumStartTime(for events: [Event]) -> Time {
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

private class ScheduleEventCell: UICollectionViewCell {
    
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

private class TimeCell: UICollectionViewCell {
    
    var time: Time! {
        didSet {
            var str: String = String(time.hour)
            if time.minutes != 0 {
                str += ":" + String(time.minutes)
            }
            str += time.isAm ? "AM" : "PM"
            label.text = str
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
        _ = label.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
