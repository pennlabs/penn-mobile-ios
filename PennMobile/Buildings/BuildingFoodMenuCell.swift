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
    var specialties: [DiningMenuItemType]
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
                [
                    DiningMenuItem(name: "Corn", details: "some corn", specialties: [.vegan, .vegetarian]),
                    DiningMenuItem(name: "Spaghettigeddon", details: "by clint", specialties: [.jain, .lowGluten]),
                    DiningMenuItem(name: "Grilled Magicarp", details: "*struggles*", specialties: [.seafood]),
                    DiningMenuItem(name: "Mystery Meat", details: "sold by a traveling salesman", specialties: []),
                ],
                [
                    DiningMenuItem(name: "Corn", details: "some corn", specialties: [.vegan, .vegetarian]),
                    DiningMenuItem(name: "Spaghettigeddon", details: "by clint", specialties: [.jain, .lowGluten]),
                    DiningMenuItem(name: "Grilled Magicarp", details: "*struggles*", specialties: [.seafood]),
                    DiningMenuItem(name: "Mystery Meat", details: "sold by a traveling salesman", specialties: [.jain]),
                ],
                [
                    DiningMenuItem(name: "Corn", details: "some corn", specialties: [.vegan, .vegetarian]),
                    DiningMenuItem(name: "Spaghettigeddon", details: "by clint", specialties: [.jain, .lowGluten]),
                    DiningMenuItem(name: "Grilled Magicarp", details: "*struggles*", specialties: [.seafood]),
                    DiningMenuItem(name: "Mystery Meat", details: "sold by a traveling salesman", specialties: []),
                ],
                [
                    DiningMenuItem(name: "Corn", details: "some corn", specialties: [.vegan, .vegetarian]),
                    DiningMenuItem(name: "Spaghettigeddon", details: "by clint", specialties: [.jain, .lowGluten]),
                    DiningMenuItem(name: "Grilled Magicarp", details: "*struggles*", specialties: [.seafood]),
                    DiningMenuItem(name: "Mystery Meat", details: "sold by a traveling salesman", specialties: [.seafood]),
                ]
            ]
            self.menu = tempMenu
        }
    }
    
    fileprivate var menu: [[DiningMenuItem]]? {
        didSet {
            if let _ = menu {
                setupCell(menu: menu!)
            }
            menuTableView.reloadData()
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
    
    fileprivate func setupCell(menu: [[DiningMenuItem]]) {
        menuTableView.reloadData()
    }
}

// MARK: - Menu Table View Datasource
extension BuildingFoodMenuCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = menu, menu!.count > section else { return 0 }
        return menu![section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DiningMenuItemCell.identifier) as? DiningMenuItemCell,
            let menu = menu, menu.count > indexPath.section,
            menu[indexPath.section].count > indexPath.row
        else { return UITableViewCell() }
        
        cell.menuItem = menu[indexPath.section][indexPath.row]
        
        return cell
    }
    
    // MARK: Header/Footer Methods
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
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
        let tableView = UITableView(frame: safeArea.frame, style: .grouped)
        tableView.register(DiningMenuItemCell.self, forCellReuseIdentifier: DiningMenuItemCell.identifier)
        tableView.isUserInteractionEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
