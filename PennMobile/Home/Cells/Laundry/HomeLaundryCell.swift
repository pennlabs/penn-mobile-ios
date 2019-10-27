//
//  HomeLaundryCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomeLaundryCell: UITableViewCell, HomeCellConformable {    
    static var identifier: String = "laundryCell"
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 310.0 + HomeViewController.cellSpacing
    }
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeLaundryCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var room: LaundryRoom!
    
    var cardView: UIView! = UIView()

    fileprivate let padding: CGFloat = UIView.padding
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    fileprivate var dividerLine: UIView!
    
    fileprivate var washerView: LaundryMachinesView!
    fileprivate var dryerView: LaundryMachinesView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Item
extension HomeLaundryCell {
    fileprivate func setupCell(with item: HomeLaundryCellItem) {
        room = item.room
        primaryTitleLabel.text = room.name
        secondaryTitleLabel.text = "LAUNDRY - " + room.building.uppercased()
        washerView.reloadData()
        dryerView.reloadData()
    }
}

// MARK: - LaundryMachinesViewDataSource
extension HomeLaundryCell: LaundryMachinesViewDataSource {
    func getMachines(_ machinesView: LaundryMachinesView) -> [LaundryMachine] {
        return machinesView.isWasher ? room.washers : room.dryers
    }
}

// MARK: - LaundryMachineViewDelegate
extension HomeLaundryCell: LaundryMachineViewDelegate {
    var allowMachineNotifications: Bool {
        guard let delegate = delegate as? LaundryMachineCellTappable else { return false }
        return delegate.allowMachineNotifications
    }
    
    func handleMachineCellTapped(for machine: LaundryMachine, _ updateCellIfNeeded: @escaping () -> Void) {
        guard let delegate = delegate as? LaundryMachineCellTappable else { return }
        delegate.handleMachineCellTapped(for: machine, updateCellIfNeeded)
    }
}

// MARK: - Prepare UI Elements
extension HomeLaundryCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareWasherDryerMachineViews()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        cardView.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: padding).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -padding).isActive = true
        safeArea.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -padding).isActive = true
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
    
    // MARK: Machine View
    private func prepareWasherDryerMachineViews() {
        washerView = getMachineView(isWasher: true)
        dryerView = getMachineView(isWasher: false)
        
        cardView.addSubview(washerView)
        cardView.addSubview(dryerView)
        
        let height = LaundryMachinesView.height
        _ = washerView.anchor(dividerLine.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: height)
        
        _ = dryerView.anchor(washerView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 6, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    private func getMachineView(isWasher: Bool) -> LaundryMachinesView {
        let machinesView = LaundryMachinesView(frame: .zero, isWasher: isWasher)
        machinesView.dataSource = self
        machinesView.delegate = self
        machinesView.translatesAutoresizingMaskIntoConstraints = false
        return machinesView
    }
}

// MARK: - UI Element Definitions
extension HomeLaundryCell {
    
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
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
