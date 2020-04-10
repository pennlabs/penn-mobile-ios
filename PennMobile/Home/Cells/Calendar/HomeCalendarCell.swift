//
//  HomeCalendarCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

final class HomeCalendarCell: UITableViewCell, HomeCellConformable {
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
        return (CGFloat(item.events?.count ?? 0) * UniversityNotificationCell.cellHeight) + HomeCellHeader.height + (Padding.pad * 3)
    }
    
    var events: [CalendarEvent]?
    
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()

    fileprivate var calendarEventTableView: UITableView!
    
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
extension HomeCalendarCell {
    fileprivate func setupCell(with item: HomeCalendarCellItem) {
        events = item.events
        calendarEventTableView.reloadData()
        header.secondaryTitleLabel.text = "UNIVERSITY CALENDAR"
        header.primaryTitleLabel.text = "Upcoming Events"
    }
}

// MARK: - UITableViewDataSource
extension HomeCalendarCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversityNotificationCell.identifier, for: indexPath) as! UniversityNotificationCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let event = events![indexPath.row]
        cell.calendarEvent = event
        return cell
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeCalendarCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareHeader()
        prepareTableView()
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
    
    // MARK: TableView
    fileprivate func prepareTableView() {
        calendarEventTableView = getEventTableView()
        cardView.addSubview(calendarEventTableView)
        
        calendarEventTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(cardView)
            make.trailing.equalTo(cardView)
            make.top.equalTo(header.snp.bottom).offset(pad)
            make.bottom.equalTo(cardView.snp.bottom).offset(-pad)
        }
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
    
    fileprivate func getEventTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(UniversityNotificationCell.self, forCellReuseIdentifier: UniversityNotificationCell.identifier)
        return tableView
    }
}



