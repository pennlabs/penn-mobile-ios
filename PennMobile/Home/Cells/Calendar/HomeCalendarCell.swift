//
//  HomeCalendarCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

final class HomeCalendarCell: UITableViewCell, HomeCellConformable {
    var cardView: UIView! = UIView()
    
    var delegate: ModularTableViewCellDelegate!
    
    static var identifier: String = "calendarCell"
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeCalendarCellItem else { return }
            setupCell(with: item)
        }
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeCalendarCellItem else { return 0.0 }
        // cell height = (venues * venueHeight) + header + footer + cellInset
        return (CGFloat(item.events?.count ?? 0) * UniversityNotificationCell.cellHeight) + (90.0 + 38.0 + 20.0)
    }
    
    var events: [CalendarEvent]?
    
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    fileprivate var calendarEventTableView: UITableView!
    
    // Mark: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI Elements
extension HomeCalendarCell {
    fileprivate func setupCell(with item: HomeCalendarCellItem) {
        events = item.events
        print(events?.count ?? 0)
        calendarEventTableView.reloadData()
        secondaryTitleLabel.text = "UNIVERSITY NOTIFICATIONS"
        primaryTitleLabel.text = "Upcoming University Events"
    }
}

// MARK: - UITableViewDataSource
extension HomeCalendarCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversityNotificationCell.identifier, for: indexPath) as! UniversityNotificationCell
        let event = events![indexPath.row]
        cell.calendarEvent = event
        return cell
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeCalendarCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareTableView()
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
    
    // Mark: TableView
    fileprivate func prepareTableView() {
        calendarEventTableView = getEventTableView()
        
        cardView.addSubview(calendarEventTableView)
        
        calendarEventTableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        calendarEventTableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor,
                                                    constant: safeInsetValue / 2).isActive = true
        calendarEventTableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor).isActive = true
        calendarEventTableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate
extension HomeCalendarCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversityNotificationCell.cellHeight
    }
}

// MARK: - Define UI Elements
extension HomeCalendarCell {
    
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
    
    fileprivate func getEventTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(UniversityNotificationCell.self, forCellReuseIdentifier: UniversityNotificationCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
}



