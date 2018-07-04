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
            self.meals = venue.meals
        }
    }
    fileprivate var meals: [DiningMeal]? {
        didSet {
            guard let meals = meals else { return }
            guard let nextOpen = venue.times?.nextOpen else {
                setupCell(meal: meals.last)
                return
            }
            
            // Find the menu cooresponding to the current timeslot
            let nextMeal = meals.first(where: { $0.description == nextOpen.meal })
            setupCell(meal: nextMeal)
        }
    }
    fileprivate var currentMeal: DiningMeal? {
        didSet {
            self.filteredStations = currentMeal?.stations.filter({ (station) -> Bool in
                if DiningStationFilter.isUselessStation
                // Make this a class possibly?
            })
        }
    }
    fileprivate var filteredStations: [DiningStation]
    
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
    
    fileprivate func setupCell(meal: DiningMeal?) {
        self.currentMeal = meal
        menuTableView.reloadData()
    }
}

// MARK: - Menu Table View Datasource
extension BuildingFoodMenuCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.currentMeal?.stations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = meals, meals!.count > section else { return 0 }
        var count = meals![section].stations.count
        for item in meals![section].stations {
            count += item.menuItem.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DiningMenuItemCell.identifier) as? DiningMenuItemCell,
            let meals = meals, meals.count > indexPath.section,
            meals[indexPath.section].stations.count > indexPath.row
        else { return UITableViewCell() }
        
        cell.station = meals[indexPath.section].stations[indexPath.row]
        
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
