//
//  HomeGSRLocationsCell.swift
//  PennMobile
//
//  Created by Josh Doman on 4/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol GSRLocationSelectable {
    func handleSelectedLocation(_ location: GSRLocation)
}

final class HomeGSRLocationsCell: UITableViewCell, HomeCellConformable {
    var delegate: ModularTableViewCellDelegate!
    static var identifier: String = "gsrLocationsCell"
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeGSRLocationsCellItem else { return }
            setupCell(with: item)
        }
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeGSRLocationsCellItem else { return 0.0 }
        return (CGFloat(item.locations.count) * GSRLocationCell.cellHeight) + HomeCellHeader.height + (Padding.pad * 3)
    }
    
    var locations: [GSRLocation]!
    
    // MARK: - UI Elements
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()
    fileprivate var tableView: UITableView!
    
    // MARK: - Init
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
extension HomeGSRLocationsCell {
    fileprivate func setupCell(with item: HomeGSRLocationsCellItem) {
        locations = item.locations
        tableView.reloadData()
        header.secondaryTitleLabel.text = "GROUP STUDY ROOMS"
        header.primaryTitleLabel.text = "New Booking"
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeGSRLocationsCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GSRLocationCell.identifier, for: indexPath) as! GSRLocationCell
        cell.location = locations[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GSRLocationCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate as? GSRLocationSelectable else { return }
        delegate.handleSelectedLocation(locations[indexPath.row])
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeGSRLocationsCell {
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
        tableView = getTableView()
        cardView.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.leading.equalTo(cardView)
            make.top.equalTo(header.snp.bottom).offset(pad)
            make.trailing.equalTo(cardView)
            make.bottom.equalTo(cardView).offset(-pad)
        }
    }
}

// MARK: - Define UI Elements
extension HomeGSRLocationsCell {
    fileprivate func getTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(GSRLocationCell.self, forCellReuseIdentifier: GSRLocationCell.identifier)
        return tableView
    }
}
