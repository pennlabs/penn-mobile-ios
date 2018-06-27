//
//  BuildingFoodMenuCell.swift
//  PennMobile
//
//  Created by dominic on 6/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

struct DiningMenuItem {
    var name: String!
    var details: String?
    var options: [DiningMenuItemType]
}

enum DiningMenuItemType {
    case vegan, lowGluten, seafood, vegetarian, jain
}

class BuildingFoodMenuCell: BuildingCell {
    
    static let identifier = "BuildingFoodMenuCell"
    static let cellHeight: CGFloat = 250
    
    override var venue: DiningVenue! {
        didSet {
            let tempMenu = [
                DiningMenuItem(name: "Corn", details: "some corn", options: [.vegan, .vegetarian]),
                DiningMenuItem(name: "Spaghettigeddon", details: "by clint", options: [.jain, .lowGluten]),
                DiningMenuItem(name: "Grilled Magicarp", details: "*struggles*", options: [.seafood]),
                DiningMenuItem(name: "Mystery Meat", details: "sold by a traveling salesman", options: []),
            ]
            setupCell(with: venue, menu: tempMenu)
        }
    }
    
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var menuTableView: UITableView!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension BuildingFoodMenuCell {
    
    fileprivate func setupCell(with venue: DiningVenue, menu: [DiningMenuItem?]) {
        
    }
}

// MARK: - Menu Table View Datasource
extension BuildingFoodMenuCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: - Menu Table View Delegate
extension BuildingFoodMenuCell: UITableViewDelegate {
    
}

// MARK: - Initialize and Prepare UI
extension BuildingFoodMenuCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()

        layoutTableView()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        addSubview(safeArea)
        NSLayoutConstraint.activate([
            safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue),
            safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue),
            safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue),
            safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue)
            ])
    }
    
    // MARK: Layout Labels
    fileprivate func layoutTableView() {
        
        menuTableView = getTableView()
        addSubview(menuTableView)
        
        _ = menuTableView.anchor(safeArea.topAnchor, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor)
    }
    
    fileprivate func getTableView() -> UITableView {
        let tableView = UITableView()
        return tableView
    }
    
    fileprivate func getDayLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = UIColor.informationYellow
        label.textAlignment = .left
        label.text = "Day"
        return label
    }
    
    fileprivate func getHourLabel() -> UILabel{
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = UIColor.informationYellow
        label.textAlignment = .right
        label.text = "Hour"
        return label
    }
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
