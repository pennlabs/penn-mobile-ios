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
    func getEmptyMessage() -> NSAttributedString
    func handleEventTapped(_ event: Event)
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
        cv.allowsSelection = true
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        return cv
    }()

    private let emptyView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = UIFont(name: "HelveticaNeue", size: 19)
        label.textColor = UIColor.labelSecondary
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
        backgroundColor = .clear

        addSubview(emptyView)

        emptyView.anchorWithConstantsToTop(topAnchor, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        emptyView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emptyView.widthAnchor.constraint(equalTo: widthAnchor, constant: -50).isActive = true

        addSubview(collectionView)

        collectionView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: ScheduleTable.topOffset, leftConstant: 0, bottomConstant: 0, rightConstant: rightOffset)

        collectionView.register(ScheduleEventCell.self, forCellWithReuseIdentifier: scheduleCell)
        collectionView.register(TimeCell.self, forCellWithReuseIdentifier: timeCell)
    }

    public var delegate: ScheduleTableDelegate! {
        didSet {
            loadTimes()
            emptyView.isHidden = !events.isEmpty
            emptyView.attributedText = delegate.getEmptyMessage()
        }
    }

    private func loadTimes() {
        times = events.getTimes()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func calculateHeightForEvents(for events: [Event]) -> CGFloat {
        if events.isEmpty {
            return 100.0
        }

        let times = events.getTimes()
        let collectionViewHeight = getYOffsetForTime(for: times.count - 1, in: times, events: events, heightForHour: heightForHour)
        return topOffset + bottomOffset + collectionViewHeight
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

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = events[indexPath.item]
        delegate.handleEventTapped(event)
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
        return (heightForHour * CGFloat(endTime.rawMinutes() - startTime.rawMinutes()) / 60.0).rounded()
    }

    func collectionView(collectionView: UICollectionView, widthForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
//        let conflictingEvents = maxConflictingEvents(for: events[indexPath.item])
//
//        if conflictingEvents.isEmpty { return 0 }
//
//        var count = conflictingEvents.count
//        let minCellWidth = cellWidth(numberOfConflictingEvents: count, width: width)
//
//        if indexPath.item == 0 || count == 1 || conflictingEvents[0] == events[indexPath.item] {
//            return minCellWidth
//        }
//
//        var remainingWidth = width
//
//        for conflictingEvent in conflictingEvents {
//            let index = events.index { (event) -> Bool in
//                event == conflictingEvent
//            }
//
//            if let index = index, index < indexPath.item {
//                let width = self.collectionView(collectionView: collectionView, widthForCellAtIndexPath: IndexPath(item: index, section: 1), width: width)
//
//                remainingWidth -= width
//                count -= 1
//            }
//        }
//
//        var calculatedWidth = cellWidth(numberOfConflictingEvents: count, width: remainingWidth)
//
//        if calculatedWidth > minCellWidth {
//            for conflictingEvent in conflictingEvents {
//                let index = events.index { (event) -> Bool in
//                    event == conflictingEvent
//                }
//
//                if let index = index, index < indexPath.item {
//                    let prevXOffset = self.collectionView(collectionView: collectionView, xOffsetForCellAtIndexPath: IndexPath(item: index, section: 1) ,  width: width)
//
//                    if prevXOffset < calculatedWidth && prevXOffset > 0 {
//                        calculatedWidth = prevXOffset
//                    }
//                }
//            }
//        }
//
//        return calculatedWidth.rounded()
        return width.rounded()
    }

    private func cellWidth(numberOfConflictingEvents: Int, width: CGFloat) -> CGFloat {
        return (width/CGFloat(numberOfConflictingEvents)).rounded()
    }

    func collectionView(collectionView: UICollectionView, xOffsetForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
//        if indexPath.item == 0 { return 0.0 }
//
//        let event = events[indexPath.item]
//
//        let conflictingEvents = maxConflictingEvents(for: event)
//
//        let numberOfConflicts = conflictingEvents.count
//        if numberOfConflicts == 1 { return 0.0 }
//
//        var validXOffsets: [CGFloat] = [CGFloat]()
//
//        let cellWidth = self.collectionView(collectionView: collectionView, widthForCellAtIndexPath: indexPath, width: width)
//
//        var nextOffset: CGFloat = 0.0
//        while nextOffset < width && nextOffset != width {
//            validXOffsets.append(nextOffset)
//            nextOffset += floor(cellWidth > width/2 ? width - cellWidth : cellWidth)
//        }
//
//        for conflictingEvent in conflictingEvents {
//
//            let index = events.index { (event) -> Bool in
//                event == conflictingEvent
//            }
//
//            if let index = index, index < indexPath.item {
//
//                let index = IndexPath(item: index, section: 1)
//
//                let prevXOffset = self.collectionView(collectionView: collectionView, xOffsetForCellAtIndexPath: index, width: width)
//
//                if let xIndex = validXOffsets.index(of: prevXOffset) {
//                    validXOffsets.remove(at: xIndex)
//                }
//            }
//        }
//        if validXOffsets.count == 0 { return 0 }
//        return validXOffsets.first!.rounded()
        return 0.0
    }

    func collectionView(collectionView: UICollectionView, yOffsetForCellAtIndexPath indexPath: IndexPath, heightForHour: CGFloat) -> CGFloat {
        if indexPath.section == 0 {
            return ScheduleTable.getYOffsetForTime(for: indexPath.item, in: times, events: events, heightForHour: heightForHour)
        }

        let event = events[indexPath.item]
        let index = times.firstIndex(of: event.startTime)!
        return ScheduleTable.getYOffsetForTime(for: index, in: times, events: events, heightForHour: heightForHour)
    }

    static func getYOffsetForTime(for index: Int, in times: [Time], events: [Event], heightForHour: CGFloat) -> CGFloat {
        let time = times[index]
        if index == 0 {
            return 0.0
        } else {
            let prevTime = times[index - 1]
            var prevTimeIsStartTime = false
            for event in events {
                if time == event.endTime && prevTime == event.startTime {
                    prevTimeIsStartTime = true
                }
            }
            let prevYOffset = getYOffsetForTime(for: index - 1, in: times, events: events, heightForHour: heightForHour)
            let diff = time.rawMinutes() - prevTime.rawMinutes()
            if prevTimeIsStartTime {
                return (heightForHour * CGFloat(diff) / 60.0 + prevYOffset).rounded()
            } else {
                return (heightForHour * min(1.5, CGFloat(diff) / 60.0) + prevYOffset).rounded()
            }
        }
    }

    // returns all conflicting events, including the event itself, when most conflicting events occur
    private func maxConflictingEvents(for event: Event) -> [Event] {
        return [event]// event.getMaxConflictingEvents(for: events)
    }

    private func maximumNumberConflictingEvents(for event: Event) -> Int {
        // return maxConflictingEvents(for: event).count
        return maxConflictingEvents(for: event).count
    }

    // returns the minimum startTime
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
        label.textColor = .labelSecondary
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
