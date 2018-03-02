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
    static var identifier = "laundryCell"
    static var cellHeight: CGFloat = 400.0

    var delegate: HomeCellDelegate!
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelLaundryItem else { return }
            setupCell(with: item)
        }
    }
    
    fileprivate var roomLabel: UILabel!
    fileprivate var roomFloorLabel: UILabel!
    fileprivate var washersLabel: UILabel!
    fileprivate var dryersLabel: UILabel!
    fileprivate var numWashersLabel: UILabel!
    fileprivate var numDryersLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI Elements
extension HomeLaundryCell {
    fileprivate func prepareUI() {
        prepareLabels()
    }
    
    // MARK: Labels
    
    fileprivate func prepareLabels() {
        roomLabel = getRoomLabel(fontSize: 14)
        roomFloorLabel = getRoomLabel(fontSize: 24)
        washersLabel = getWasherDryerLabel(isWasher: true)
        dryersLabel = getWasherDryerLabel(isWasher: false)
        numWashersLabel = getNumMachinesLabel()
        numDryersLabel = getNumMachinesLabel()
    }
    
    private func getRoomLabel(fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: fontSize)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }
    
    private func getWasherDryerLabel(isWasher: Bool) -> UILabel {
        let label = getRoomLabel(fontSize: 14)
        label.text = isWasher ? "Washers" : "Dryers"
        return label
    }
    
    private func getNumMachinesLabel() -> UILabel {
        let label = getRoomLabel(fontSize: 16)
        label.textColor = .warmGrey
        label.textAlignment = .right
        return label
    }
}

// MARK: - Setup Item
extension HomeLaundryCell {
    fileprivate func setupCell(with item: HomeViewModelLaundryItem) {
        print(item.room.name)
    }
}
