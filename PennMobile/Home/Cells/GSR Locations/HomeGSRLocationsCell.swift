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
    var cardView: UIView! = UIView()
    
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
        return (CGFloat(item.locations.count) * GSRLocationCell.cellHeight) + (90.0 + 20.0) + 8
    }
    
    var locations: [GSRLocation]!
    
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    fileprivate var tableView: UITableView!
    
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
extension HomeGSRLocationsCell {
    fileprivate func setupCell(with item: HomeGSRLocationsCellItem) {
        locations = item.locations
        tableView.reloadData()
        secondaryTitleLabel.text = "GSR LOCATIONS"
        primaryTitleLabel.text = "GSR Booking"
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
        cell.isHomePageCell = true
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
    
    // MARK: TableView
    fileprivate func prepareTableView() {
        tableView = getTableView()
        
        cardView.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 4).isActive = true
        tableView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -4).isActive = true
    }
}

// MARK: - Define UI Elements
extension HomeGSRLocationsCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
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
    
    fileprivate func getTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(GSRLocationCell.self, forCellReuseIdentifier: GSRLocationCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
}
