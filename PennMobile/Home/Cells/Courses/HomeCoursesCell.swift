//
//  HomeCoursesCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/11/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol BuildingMapSelectable {
    func handleBuildingSelected(searchTerm: String)
}

final class HomeCoursesCell: UITableViewCell, HomeCellConformable {
    var cardView: UIView! = UIView()
    
    var delegate: ModularTableViewCellDelegate!
    
    static var identifier: String = "coursesCell"
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeCoursesCellItem else { return }
            setupCell(with: item)
        }
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeCoursesCellItem else { return 0.0 }
        let events = item.courses.getEvents()
        let scheduleHeight = ScheduleTable.calculateHeightForEvents(for: events)
        return 110 + scheduleHeight
    }
    
    var courses: [Course]!
    
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    fileprivate var courseScheduleTable: ScheduleTable!
    
    // Mark: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI Elements
extension HomeCoursesCell {
    fileprivate func setupCell(with item: HomeCoursesCellItem) {
        courses = item.courses
        if let course = courses.first {
            if course.isTaughtToday {
                primaryTitleLabel.text = "Today's Schedule"
            } else if course.isTaughtTomorrow {
                primaryTitleLabel.text = "Tomorrow's Schedule"
            } else {
                for i in 2..<7 {
                    if course.isTaughtInNDays(days: i) {
                        let dayOfWeek = Date().dateIn(days: i).dayOfWeek
                        primaryTitleLabel.text = "\(dayOfWeek)'s Schedule"
                        break
                    }
                }
            }
        } else {
            primaryTitleLabel.text = "Your Courses"
        }
        secondaryTitleLabel.text = "COURSE SCHEDULE"
        courseScheduleTable.delegate = self
        
        let coursesHeight = ScheduleTable.calculateHeightForEvents(for: courses.getEvents())
        courseScheduleTable.heightAnchor.constraint(equalToConstant: coursesHeight).isActive = true
        courseScheduleTable.reloadData()
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeCoursesCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareScheduleTable()
    }
    
    private func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        cardView.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: cardView.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -safeInsetValue).isActive = true
    }
    
    // MARK: Labels
    fileprivate func prepareTitleLabels() {
        secondaryTitleLabel = getSecondaryLabel()
        primaryTitleLabel = getPrimaryLabel()
        
        cardView.addSubview(secondaryTitleLabel)
        cardView.addSubview(primaryTitleLabel)
        
        secondaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        secondaryTitleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        primaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        primaryTitleLabel.topAnchor.constraint(equalTo: secondaryTitleLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    // MARK: Divider Line
    fileprivate func prepareDividerLine() {
        dividerLine = getDividerLine()
        
        cardView.addSubview(dividerLine)
        
        dividerLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        dividerLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        dividerLine.topAnchor.constraint(equalTo: primaryTitleLabel.bottomAnchor, constant: 14).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    // MARK: Schedule Table
    fileprivate func prepareScheduleTable() {
        courseScheduleTable = getScheduleTable()
        cardView.addSubview(courseScheduleTable)
        
        _ = courseScheduleTable.anchor(dividerLine.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}

extension HomeCoursesCell: ScheduleTableDelegate {
    func getEvents() -> [Event] {
        return courses.getEvents()
    }
    
    func getEmptyMessage() -> String {
        return "No Courses Today"
    }
    
    func handleEventTapped(_ event: Event) {
        guard let delegate = delegate as? BuildingMapSelectable,
            let course = (courses.filter { $0.getEvent() == event }).first,
            let searchTerm = course.building else { return }
        delegate.handleBuildingSelected(searchTerm: searchTerm)
    }
}

// MARK: - Define UI Elements
extension HomeCoursesCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .allbirdsGrey
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getScheduleTable() -> ScheduleTable {
        let scheduleView = ScheduleTable(frame: .zero)
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        scheduleView.clipsToBounds = true
        return scheduleView
    }
}
