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
    static let cellHeight: CGFloat = 200
    
    static let menuHeaderHeight: CGFloat = 40.0
    
    var building: BuildingMenusDisplayable! {
        didSet {
            self.meals = building.getMeals()
        }
    }
    
    
    fileprivate var meals: [DiningMeal]? {
        didSet {
            guard let meals = meals else { return }
            guard let nextOpen = building.getTimes()?.nextOpen else {
                self.currentMeal = meals.last
                return
            }
            
            // Find the menu cooresponding to the current timeslot
            let nextMeal = meals.first(where: { $0.description == nextOpen.meal })
            self.currentMeal = nextMeal
        }
    }
    fileprivate var currentMeal: DiningMeal? {
        didSet {
            self.filteredStations = currentMeal?.usefulStations()
            setupCell()
        }
    }
    fileprivate var filteredStations: [DiningStation]?
    
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    var fogView: UIView?
    var menuTableView: UITableView!
    
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
    
    func setupCell() {
        menuTableView.reloadData()
    }
}

// MARK: - Menu Table View Datasource
extension BuildingFoodMenuCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredStations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filteredStations = filteredStations, filteredStations.count > section else { return 0 }
        return filteredStations[section].menuItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DiningMenuItemCell.identifier) as? DiningMenuItemCell,
            let filteredStations = filteredStations, filteredStations.count > indexPath.section,
            filteredStations[indexPath.section].menuItem.count > indexPath.row
        else { return UITableViewCell() }
        
        cell.menuItem = filteredStations[indexPath.section].menuItem[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let filteredStations = filteredStations, filteredStations.count > section else { return nil }
        return filteredStations[section].description
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: BuildingFoodMenuCell.menuHeaderHeight))
        label.textColor = UIColor.darkGray
        label.font = UIFont.primaryInformationFont
        label.textAlignment = .center
        
        if let filteredStations = filteredStations, filteredStations.count > section {
            label.text = filteredStations[section].description.uppercased()
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BuildingFoodMenuCell.menuHeaderHeight
    }
    
    func getMenuRequiredHeight() -> CGFloat {
        return menuTableView.contentSize.height
        /*
        var total: CGFloat = 0.0
        total += (2.0 * safeInsetValue)
        guard let sections = filteredStations,sections.count > 0 else { return total }
        
        total += (tableView(menuTableView, heightForHeaderInSection: 0) * CGFloat(sections.count))
        total += ((menuTableView.footerView(forSection: 0)?.frame.height ?? 0.0) * CGFloat(sections.count))
        
        for each in sections.indices {
            total += (CGFloat(sections[each].menuItem.count) * DiningMenuItemCell.cellHeight)
        }
        return total*/
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
            safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue * 2),
            safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue * 2),
            safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue),
            safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue)
            ])
    }
    
    // MARK: Fog View
    func addFogView() {
        fogView = getFogView()
        addSubview(fogView!)
        _ = fogView!.anchor(nil, left: self.leftAnchor, bottom: self.menuTableView.bottomAnchor, right: self.rightAnchor, heightConstant: 80.0)
    }
    
    fileprivate func getFogView() -> UIView {
        let fogView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width + 100.0, height: 80.0))
        let gradient = CAGradientLayer()
        gradient.frame = fogView.frame
        gradient.colors = [UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0).cgColor, UIColor.white.cgColor]
        fogView.layer.insertSublayer(gradient, at: 0)
        return fogView
    }
    
    // MARK: Layout Labels
    fileprivate func layoutTableView() {
        
        menuTableView = getTableView()
        addSubview(menuTableView)
        
        _ = menuTableView.anchor(safeArea.topAnchor, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor)
    }
    
    fileprivate func getTableView() -> MenuTableView {
        let tableView = MenuTableView(frame: safeArea.frame, style: .grouped)
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
