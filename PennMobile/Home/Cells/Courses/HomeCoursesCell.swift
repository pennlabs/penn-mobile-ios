//
//  HomeCoursesCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/11/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol CourseRefreshable {
    func handleCourseRefresh()
}

protocol CourseLoginable {
    func handleLoggingIn()
}

protocol BuildingMapSelectable {
    func handleBuildingSelected(searchTerm: String)
}

final class HomeCoursesCell: UITableViewCell, HomeCellConformable {    

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
        return HomeCellHeader.height + (Padding.pad * 3) + scheduleHeight
    }
    
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()
    
    var courses: [Course]!
    fileprivate var courseScheduleTable: ScheduleTable!
    fileprivate var refreshButton: UIButton!
    fileprivate var courseTableHeightConstraint: NSLayoutConstraint?
    fileprivate var enableCoursesView: UIView!
    fileprivate var enableCourseLabel: UILabel!
    
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
        header.primaryTitleLabel.text = "\(item.weekday)'s Schedule"
        header.secondaryTitleLabel.text = "COURSES"
        
        if courses != item.courses {
            courses = item.courses
            courseScheduleTable.delegate = self

            if let heightConstraint = self.courseTableHeightConstraint {
                self.courseScheduleTable.removeConstraint(heightConstraint)
            }
            
            let coursesHeight = ScheduleTable.calculateHeightForEvents(for: item.courses.getEvents())
            self.courseTableHeightConstraint = self.courseScheduleTable.heightAnchor.constraint(equalToConstant: coursesHeight)
            self.courseTableHeightConstraint?.isActive = true
            self.courseScheduleTable.reloadData()
        }
        
        refreshButton.isHidden = !item.isOnHomeScreen
        enableCoursesView.isHidden = true
        courseScheduleTable.isHidden = false
        header.secondaryTitleLabel.isHidden = !item.isOnHomeScreen
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeCoursesCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareHeader()
        prepareRefreshButton()
        prepareScheduleTable()
        prepareEnableCoursesView()
    }

    // MARK: Safe Area and Header
    fileprivate func prepareSafeArea() {
        cardView.addSubview(safeArea)
        safeArea.prepare()
    }

    fileprivate func prepareHeader() {
        safeArea.addSubview(header)
        header.prepare()
    }
    
    // MARK: Schedule Table
    fileprivate func prepareScheduleTable() {
        courseScheduleTable = getScheduleTable()
        cardView.addSubview(courseScheduleTable)
        
        _ = courseScheduleTable.anchor(header.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: pad, leftConstant: 0, bottomConstant: -pad, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    // MARK: Refresh Button
    fileprivate func prepareRefreshButton() {
        refreshButton = UIButton()
        refreshButton.tintColor = UIColor.navigation
        refreshButton.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(refreshButton)
        
        refreshButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        refreshButton.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    @objc private func refreshButtonTapped(_ sender: Any) {
        guard let delegate = delegate as? CourseRefreshable else { return }
        delegate.handleCourseRefresh()
    }
}

extension HomeCoursesCell: ScheduleTableDelegate {
    func getEvents() -> [Event] {
        return courses.getEvents()
    }
    
    func getEmptyMessage() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        
        let attrString = NSMutableAttributedString(string: "Nothing planned. Enjoy the day off 🎉")
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        return attrString
    }

    
    func handleEventTapped(_ event: Event) {
        guard let delegate = delegate as? BuildingMapSelectable,
            let course = (courses.filter { $0.getEvent() == event }).first,
            let searchTerm = course.building else { return }
        delegate.handleBuildingSelected(searchTerm: searchTerm)
    }
    
    @objc func handleLoggingIn(_ sender: Any) {
        guard let delegate  = delegate as? CourseLoginable else { return }
        delegate.handleLoggingIn()
    }
}

// MARK: - Define UI Elements
extension HomeCoursesCell {
    fileprivate func getScheduleTable() -> ScheduleTable {
        let scheduleView = ScheduleTable(frame: .zero)
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        scheduleView.clipsToBounds = true
        return scheduleView
    }
    
    func getEnableCoursesText() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        
        let attrString = NSMutableAttributedString(string: "Penn Mobile does not have access to your course schedule.")
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        return attrString
    }
    
    fileprivate func prepareEnableCoursesView() {
        enableCoursesView = UIView()
        enableCoursesView!.isHidden = true
        guard let enableCoursesView = enableCoursesView else { return }
        enableCoursesView.backgroundColor = .uiBackground
        cardView.addSubview(enableCoursesView)
        enableCoursesView.translatesAutoresizingMaskIntoConstraints = false
        enableCoursesView.heightAnchor.constraint(equalToConstant: 150).isActive = true
         _ = enableCoursesView.anchor(header.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        enableCoursesView.clipsToBounds = true
        
        prepareEnableCoursesLabel()
        prepareEnableCoursesButton()
    }
    
    fileprivate func prepareEnableCoursesLabel() {
        enableCourseLabel = UILabel()
        enableCourseLabel.textAlignment = .center
        enableCourseLabel.numberOfLines = 2
        enableCourseLabel.font = UIFont(name: "HelveticaNeue", size: 19)
        enableCourseLabel.textColor = UIColor.labelSecondary
        enableCourseLabel.attributedText = getEnableCoursesText()
        
        enableCourseLabel.translatesAutoresizingMaskIntoConstraints = false
    
        enableCoursesView?.addSubview(enableCourseLabel)
        enableCourseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        enableCourseLabel.topAnchor.constraint(equalTo: enableCoursesView!.topAnchor, constant: 20).isActive = true
        enableCourseLabel.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -40).isActive = true
        enableCourseLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
    }
    
    fileprivate func prepareEnableCoursesButton() {
        let loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = false
        loginButton.backgroundColor = UIColor(r: 26, g: 142, b: 221)

        let attributedString = NSMutableAttributedString(string: "Grant Permission")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.2), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
        
        loginButton.setAttributedTitle(attributedString, for: .normal)
        loginButton.titleLabel?.font = UIFont.avenirMedium.withSize(15)
        loginButton.addTarget(self, action: #selector(handleLoggingIn(_:)), for: .touchUpInside)
        
        enableCoursesView!.addSubview(loginButton)
        loginButton.topAnchor.constraint(equalTo: enableCourseLabel.bottomAnchor, constant: 20).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: enableCoursesView.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
