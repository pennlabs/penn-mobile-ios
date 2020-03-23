//
//  HomeDiningCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation
import UIKit

protocol DiningCellSelectable {
    func handleVenueSelected(_ venue: DiningVenue)
    func handleSettingsTapped(venues: [DiningVenue])
}

final class HomeDiningCell: UITableViewCell, HomeCellConformable {    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeDiningCellItem else { return }
            setupCell(with: item)
        }
    }

    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeDiningCellItem else { return 0.0 }
        return (CGFloat(item.venues.count) * DiningCell.cellHeight) + HomeCellHeader.height + (Padding.pad * 3)
    }

    static var identifier: String = "diningCell"

    var venues: [DiningVenue]?

    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()

    fileprivate var settingsButton: UIButton!
    fileprivate var venueTableView: UITableView!

    // Mark: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func settingsButtonTapped() {
        guard let delegate = delegate as? DiningCellSelectable else { return }
        guard let venues = venues else {
            delegate.handleSettingsTapped(venues: [])
            return
        }

        delegate.handleSettingsTapped(venues: venues)
    }

    @objc fileprivate func transitionButtonTapped() {}
}

// MARK: - Setup UI Elements
extension HomeDiningCell {
    fileprivate func setupCell(with item: HomeDiningCellItem) {
        venues = item.venues
        venueTableView.reloadData()

        header.secondaryTitleLabel.text = "DINING HOURS"
        header.primaryTitleLabel.text = "Favorites"
    }
}

// MARK: - UITableViewDataSource
extension HomeDiningCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiningCell.identifier, for: indexPath) as! DiningCell
        cell.venue = venues?[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeDiningCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? DiningCell {
            cell.isHomepage = true
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let venue = venues?[indexPath.row], let delegate = delegate as? DiningCellSelectable else { return }
        delegate.handleVenueSelected(venue)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DiningCell.cellHeight
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeDiningCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareHeader()
        prepareSettingsButton()
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
    
    // MARK: Settings Button
    fileprivate func prepareSettingsButton() {
        settingsButton = getSettingsButton()
        header.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { (make) in
            make.size.equalTo(21)
            make.centerY.equalTo(header)
            make.trailing.equalTo(header)
        }
    }

    // MARK: TableView
    fileprivate func prepareTableView() {
        venueTableView = getVenueTableView()
        cardView.addSubview(venueTableView)
        
        venueTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(cardView)
            make.top.equalTo(header.snp.bottom).offset(pad)
            make.trailing.equalTo(cardView)
            make.bottom.equalTo(cardView).offset(-pad)
        }
    }
}

// MARK: - Define UI Elements
extension HomeDiningCell {
    fileprivate func getSettingsButton() -> UIButton {
        let button = UIButton()
        button.tintColor = .labelSecondary
        button.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }

    fileprivate func getVenueTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(DiningCell.self, forCellReuseIdentifier: DiningCell.identifier)
        return tableView
    }
}
