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
    static var cellHeight: CGFloat = 450.0

    var delegate: HomeCellDelegate!
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelLaundryItem else { return }
            setupCell(with: item)
        }
    }
    
    var room: LaundryRoom!
    
    var cardView: UIView! = UIView()

    fileprivate var roomLabel: UILabel!
    fileprivate var buildingLabel: UILabel!
    fileprivate var hairline: UIView!
    
    fileprivate var washerView: LaundryMachinesView!
    fileprivate var dryerView: LaundryMachinesView!
    fileprivate var graphView: LaundryGraphView!
    
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
        prepareHairline()
        prepareWasherDryerMachineViews()
        prepareGraphView()
    }
    
    // MARK: Labels
    
    fileprivate func prepareLabels() {
        roomLabel = getRoomLabel(fontSize: 24)
        buildingLabel = getRoomLabel(fontSize: 14)
        buildingLabel.textColor = .warmGrey
        
        cardView.addSubview(roomLabel)
        cardView.addSubview(buildingLabel)
        
        roomLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20).isActive = true
        roomLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10).isActive = true
        
        buildingLabel.leadingAnchor.constraint(equalTo: roomLabel.leadingAnchor).isActive = true
        buildingLabel.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: 5).isActive = true
    }
    
    private func getRoomLabel(fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: fontSize)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: Machine View
    private func prepareWasherDryerMachineViews() {
        washerView = getMachineView(isWasher: true)
        dryerView = getMachineView(isWasher: false)
        
        cardView.addSubview(washerView)
        cardView.addSubview(dryerView)
        
        let height = LaundryMachinesView.height
        _ = washerView.anchor(hairline.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: height)
        
        _ = dryerView.anchor(washerView.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 6, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: height)
    }
    
    private func getMachineView(isWasher: Bool) -> LaundryMachinesView {
        let machinesView = LaundryMachinesView(frame: .zero, isWasher: isWasher)
        machinesView.dataSource = self
        machinesView.translatesAutoresizingMaskIntoConstraints = false
        return machinesView
    }
    
    // MARK: Hairline
    private func prepareHairline() {
        hairline = UIView()
        hairline.backgroundColor = .lightGray
        
        cardView.addSubview(hairline)
        _ = hairline.anchor(buildingLabel.bottomAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 10, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 1)
    }
    
    // MARK: Graph View
    private func prepareGraphView() {
        graphView = LaundryGraphView(frame: .zero)
        graphView.backgroundColor = .red
        
        cardView.addSubview(graphView)
        _ = graphView.anchor(dryerView.bottomAnchor, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: cardView.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}

// MARK: - Setup Item
extension HomeLaundryCell {
    fileprivate func setupCell(with item: HomeViewModelLaundryItem) {
        room = item.room
        roomLabel.text = room.name
        buildingLabel.text = room.building
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
