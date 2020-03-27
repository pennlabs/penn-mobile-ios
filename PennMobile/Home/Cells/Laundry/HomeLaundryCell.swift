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
        return HomeCellHeader.height + (Padding.pad * 7) + (LaundryMachinesView.height * 2)
    }
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeLaundryCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()
    
    var room: LaundryRoom!
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
        header.primaryTitleLabel.text = room.name
        header.secondaryTitleLabel.text = room.building.uppercased() + " LAUNDRY"
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
        prepareHeader()
        prepareWasherDryerMachineViews()
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
    
    // MARK: Machine View
    private func prepareWasherDryerMachineViews() {
        washerView = getMachineView(isWasher: true)
        dryerView = getMachineView(isWasher: false)
        
        cardView.addSubview(washerView)
        cardView.addSubview(dryerView)
        
        washerView.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom).offset(pad * 2)
            make.leading.equalTo(cardView)
            make.trailing.equalTo(cardView)
            make.height.equalTo(LaundryMachinesView.height)
        }
        dryerView.snp.makeConstraints { (make) in
            make.top.equalTo(washerView.snp.bottom).offset(pad * 2)
            make.leading.equalTo(cardView)
            make.trailing.equalTo(cardView)
            make.height.equalTo(LaundryMachinesView.height)
        }
    }
    
    private func getMachineView(isWasher: Bool) -> LaundryMachinesView {
        let machinesView = LaundryMachinesView(frame: .zero, isWasher: isWasher)
        machinesView.dataSource = self
        machinesView.delegate = self
        machinesView.translatesAutoresizingMaskIntoConstraints = false
        return machinesView
    }
}
