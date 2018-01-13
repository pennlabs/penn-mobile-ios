//
//  HallsSelectionViewController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2017/11/5.
//  Copyright © 2017年 PennLabs. All rights reserved.
//

import UIKit

protocol HallSelectionDelegate: class {
    func saveSelection(for halls: [LaundryHall])
}

class HallSelectionViewController: UIViewController, ShowsAlert, Trackable, IndicatorEnabled {
    
    // delegating function to pass value to LaundryOverhaulViewController
    weak var delegate: HallSelectionDelegate?
    
    fileprivate let maxNumHalls = 3
    
    var chosenHalls = [LaundryHall]() {
        didSet {
//            navigationItem.title = "\(chosenHalls.count)/\(maxNumHalls) Chosen"
//            selectionView.chosenHalls = chosenHalls
//            selectionView.prepare()
        }
    }
    
    // buildings and currentResult to update TableView
    fileprivate var buildings = [String: [LaundryHall]]()
    fileprivate var currentResults = [String: [LaundryHall]]()
    
    // current sort for the headers
    fileprivate var currentSort: [String]!
    
    // Views
    fileprivate lazy var selectionView: HallSelectionView = {
        let hsv = HallSelectionView(frame: .zero)
        hsv.delegate = self
        return hsv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // set up navbar
        navigationItem.title = "\(chosenHalls.count)/\(maxNumHalls) Chosen"
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        
        // tracking
        trackScreen("Hall Selection")
        
        // set up view and gesture recognizer
//        setUpView()
//        setUpGesture()
//        setupDictionaries()
//        setupCurrentSort()
        
        view.addSubview(selectionView)
        selectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "\(chosenHalls.count)/\(maxNumHalls) Chosen"
        selectionView.chosenHalls = chosenHalls
        selectionView.prepare()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        selectionView.updateSelectedHalls()
//        updateSelectedHalls()
    }
}

extension HallSelectionViewController: HallSelectionViewDelegate {
    func updateSelectedHalls(for halls: [LaundryHall]) {
        navigationItem.title = "\(halls.count)/\(selectionView.maxNumHalls) Chosen"
    }
    
    func handleFailureToLoadDictionary() {
        self.showAlert(withMsg: "Try reconnecting to the internet.", title: "Network API Failed", completion: nil)
    }
}

//// Mark: Select chosen halls
//extension HallSelectionViewController {
//    fileprivate func updateSelectedHalls() {
//        for hall in chosenHalls {
//            if let index = getCurrentIndex(for: hall) {
//                tableView.selectRow(at: index, animated: false, scrollPosition: .none)
//            }
//        }
//    }
//
//    private func getCurrentIndex(for hall: LaundryHall) -> IndexPath? {
//        if let section = currentSort.index(where: { (building) -> Bool in
//            return building == hall.building
//        }), let halls = currentResults[hall.building] {
//            if let row = halls.index(of: hall) {
//                return IndexPath(row: row, section: section)
//            }
//        }
//        return nil
//    }
//}
//
//// Mark: Sorting algorithm
//extension HallSelectionViewController {
//    fileprivate func sortHeaders(for headers: [String]) -> [String] {
//        return headers.sorted {
//            let count1 = buildings[$0]!.filter({ (hall) -> Bool in
//                return chosenHalls.contains(hall)
//            }).count
//
//            let count2 = buildings[$1]!.filter({ (hall) -> Bool in
//                return chosenHalls.contains(hall)
//            }).count
//
//            if count1 == count2 {
//                return $0 == "Quad" // By default, make the quad appear first
//            }
//
//            return count1 > count2
//        }
//    }
//}
//
//// Mark: Functions to Set Up View, Gesture Recognizer, Dictionaries, and Sorted Headers
//extension HallSelectionViewController {
//    fileprivate func setUpView() {
//        self.view.backgroundColor = UIColor.white
//        view.addSubview(searchBar)
//        view.addSubview(tableView)
//        view.addSubview(emptyView)
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        emptyView.translatesAutoresizingMaskIntoConstraints = false
//        setUpSearchBar()
//        setUpTableView()
//        setUpEmptyView()
//    }
//
//    fileprivate func setUpSearchBar() {
//        searchBar.searchBarStyle = UISearchBarStyle.prominent
//        searchBar.placeholder = "Search..."
//        searchBar.sizeToFit()
//        searchBar.isTranslucent = false
//        searchBar.backgroundImage = UIImage()
//        searchBar.delegate = self
//        searchBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
//        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
//        searchBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
//    }
//
//    fileprivate func setUpTableView() {
//        self.tableView.rowHeight = 50
//        _ = tableView.anchor(searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        self.tableView.allowsMultipleSelection = true
//    }
//
//    fileprivate func setUpEmptyView() {
//        _ = emptyView.anchor(tableView.topAnchor, left: tableView.leftAnchor, bottom: tableView.bottomAnchor, right: tableView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//    }
//
//    fileprivate func setUpGesture() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        tapGestureRecognizer.delegate = self
//        view.addGestureRecognizer(tapGestureRecognizer)
//        //revealViewController().frontViewController.view.addGestureRecognizer(tapGestureRecognizer)
//    }
//
//    fileprivate func setupDictionaries() {
//        guard let hallsDict: [Int: LaundryHall] = LaundryAPIService.instance.idToHalls else {
//            attemptToLoadDictionary()
//            return
//        }
//
//        for (_, hall) in hallsDict {
//            let building = hall.building
//            if building != "Unknown" {
//                if buildings[building] == nil {
//                    var hallsForBuilding = [LaundryHall]()
//                    hallsForBuilding.append(hall)
//                    buildings[building] = hallsForBuilding
//                } else {
//                    buildings[building]!.append(hall)
//                }
//            }
//        }
//
//        for (building, halls) in buildings {
//            buildings[building] = halls.sorted(by: { (hall1, hall2) -> Bool in
//                return hall1.id < hall2.id
//            })
//        }
//
//        for hall in chosenHalls {
//            var arr = buildings[hall.building]
//            if let index = arr?.index(of: hall) {
//                arr?.remove(at: index)
//            }
//            arr?.insert(hall, at: 0)
//            buildings[hall.building] = arr
//        }
//
//        currentResults = buildings
//    }
//
//    fileprivate func setupCurrentSort() {
//        self.currentSort = sortHeaders(for: Array(buildings.keys))
//    }
//
//    private func attemptToLoadDictionary() {
//        showActivity()
//        LaundryAPIService.instance.loadIds { (success) in
//            DispatchQueue.main.async {
//                self.hideActivity()
//                if !success {
//                    self.showAlert(withMsg: "Try reconnecting to the internet.", title: "Network API Failed", completion: nil)
//                    return
//                }
//
//                self.setupDictionaries()
//                self.setupCurrentSort()
//                self.tableView.reloadData()
//            }
//        }
//    }
//}
//
// Mark: Hall selection
extension HallSelectionViewController {
    @objc fileprivate func handleSave() {
        delegate?.saveSelection(for: selectionView.chosenHalls)
        _ = selectionView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func handleCancel() {
        _ = selectionView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
//
//// Mark: Functions implementing Gesture Recognizer
//extension HallSelectionViewController: UIGestureRecognizerDelegate {
//    @objc fileprivate func tapGesture(_ sender: Any) {
//        if searchBar.isFirstResponder {
//            searchBar.resignFirstResponder()
//        }
//    }
//
//    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        return touch.location(in: tableView).y < 0
//    }
//}
//
//// Mark: Functions implementing TableView
//extension HallSelectionViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return currentResults.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let key = currentSort[section]
//        return currentResults[key]!.count
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return currentSort[section]
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
//        let key = currentSort[indexPath.section]
//        let hall = currentResults[key]![indexPath.row]
//        cell.textLabel?.text = hall.name
//        cell.accessoryType = cell.isSelected ? .checkmark : .none
//        cell.selectionStyle = .none
//        if chosenHalls.contains(hall) {
//            cell.accessoryType = .checkmark
//            cell.textLabel?.textColor = .black
//        } else {
//            cell.textLabel?.textColor = chosenHalls.count == maxNumHalls ? UIColor.lightGray : UIColor.black
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if chosenHalls.count < maxNumHalls {
//            let key = currentSort[indexPath.section]
//            let hall = currentResults[key]![indexPath.row]
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//            chosenHalls.append(hall)
//
//            if chosenHalls.count == maxNumHalls {
//                tableView.reloadData()
//                updateSelectedHalls()
//            }
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let key = currentSort[indexPath.section]
//        let hall = currentResults[key]![indexPath.row]
//        if let index = chosenHalls.index(of: hall) {
//            chosenHalls.remove(at: index)
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }
//
//        if chosenHalls.count == maxNumHalls - 1 {
//            tableView.reloadData()
//            updateSelectedHalls()
//        }
//    }
//
//    // Resigns the keyboard if up once the user starts to scroll through the listings
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if searchBar.isFirstResponder {
//            searchBar.resignFirstResponder()
//        }
//    }
//}
//
//// Mark: Functions implementing SearchBar
//extension HallSelectionViewController: UISearchBarDelegate, UISearchDisplayDelegate {
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            currentResults = buildings
//            currentSort = sortHeaders(for: Array(buildings.keys))
//            self.showEmptyViewIfNeeded()
//            tableView.reloadData()
//            updateSelectedHalls()
//            return
//        }
//
//        currentResults = [String: [LaundryHall]]()
//        for (building, laundryHalls) in buildings {
//            if building.lowercased().contains(searchText.lowercased()) {
//                currentResults[building] = laundryHalls
//            } else {
//                var toAdd:[LaundryHall]  = []
//                for hall in laundryHalls {
//                    if hall.name.lowercased().contains(searchText.lowercased()) {
//                        toAdd.append(hall)
//                    }
//                }
//                if !toAdd.isEmpty {
//                    currentResults[building] = toAdd
//                }
//            }
//        }
//        currentSort = sortHeaders(for: Array(currentResults.keys))
//        self.showEmptyViewIfNeeded()
//        tableView.reloadData()
//        updateSelectedHalls()
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if searchBar.isFirstResponder {
//            searchBar.resignFirstResponder()
//        }
//    }
//
//}
//
//// Mark: Functions implementing EmptyView
//extension HallSelectionViewController {
//    internal func showEmptyViewIfNeeded() {
//        emptyView.isHidden = !currentResults.isEmpty
//        tableView.isHidden = currentResults.isEmpty
//    }
//}

