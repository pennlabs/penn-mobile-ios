//
//  HallSelectionView.swift
//  PennMobile
//
//  Created by Josh Doman on 11/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

protocol RoomSelectionViewDelegate: AnyObject {
    func updateSelectedRooms(for rooms: [LaundryRoom])
    func handleFailureToLoadDictionary()
}

class RoomSelectionView: UIView, IndicatorEnabled {

    // delegating function to pass value to LaundryOverhaulViewController
    weak var delegate: RoomSelectionViewDelegate?

    let maxNumRooms = 3

    public fileprivate(set) var chosenRooms = [LaundryRoom]()

    // buildings and currentResult to update TableView
    fileprivate var buildings = [String: [LaundryRoom]]()
    fileprivate var currentResults = [String: [LaundryRoom]]()

    // current sort for the headers
    fileprivate var currentSort: [String]!

    // Views
    fileprivate var tableView: UITableView = UITableView()
    fileprivate lazy var searchBar = UISearchBar()
    fileprivate let emptyView: EmptyView = {
        let ev = EmptyView()
        ev.isHidden = true
        return ev
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // delegation
        searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    public func prepare(with rooms: [LaundryRoom]?) {
        if let chosenRooms = rooms {
            self.chosenRooms = chosenRooms
        }
        // set up view and gesture recognizer
        setUpView()
        setupDictionaries()
        setupCurrentSort()
        selectChosenRooms()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension RoomSelectionView {
    fileprivate func setUpView() {
        self.backgroundColor = UIColor.uiBackground
        addSubview(searchBar)
        addSubview(tableView)
        addSubview(emptyView)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        setUpSearchBar()
        setUpTableView()
        setUpEmptyView()
    }

    fileprivate func setUpSearchBar() {
        // searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        // searchBar.isTranslucent = false
        // searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        searchBar.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        searchBar.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    fileprivate func setUpTableView() {
        self.tableView.rowHeight = 50
        _ = tableView.anchor(searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.allowsMultipleSelection = true
    }

    fileprivate func setUpEmptyView() {
        _ = emptyView.anchor(tableView.topAnchor, left: tableView.leftAnchor, bottom: tableView.bottomAnchor, right: tableView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    fileprivate func setupCurrentSort() {
        self.currentSort = sortHeaders(for: Array(buildings.keys))
    }
}

// MARK: - Sorting
extension RoomSelectionView {
    fileprivate func sortHeaders(for headers: [String]) -> [String] {
        return headers.sorted {
            let count1 = buildings[$0]!.filter({ (room) -> Bool in
                return chosenRooms.contains(room)
            }).count

            let count2 = buildings[$1]!.filter({ (room) -> Bool in
                return chosenRooms.contains(room)
            }).count

            if count1 == count2 {
                return $0 == "Quad" // By default, make the quad appear first
            }

            return count1 > count2
        }
    }

    fileprivate func setupDictionaries() {
        guard let roomsDict: [Int: LaundryRoom] = LaundryAPIService.instance.idToRooms else {
            attemptToLoadDictionary()
            return
        }

        for (_, room) in roomsDict {
            let building = room.building
            if building != "Unknown" {
                if buildings[building] == nil {
                    var roomsForBuilding = [LaundryRoom]()
                    roomsForBuilding.append(room)
                    buildings[building] = roomsForBuilding
                } else {
                    buildings[building]!.append(room)
                }
            }
        }

        for (building, rooms) in buildings {
            buildings[building] = rooms.sorted(by: { (room1, room2) -> Bool in
                return room1.id < room2.id
            })
        }

        for room in chosenRooms.reversed() {
            var arr = buildings[room.building]
            if let index = arr?.firstIndex(of: room) {
                arr?.remove(at: index)
            }
            arr?.insert(room, at: 0)
            buildings[room.building] = arr
        }

        currentResults = buildings
    }
}

// MARK: - room Selection
extension RoomSelectionView {
    public func selectChosenRooms() {
        for room in chosenRooms {
            if let index = getCurrentIndex(for: room) {
                tableView.selectRow(at: index, animated: false, scrollPosition: .none)
            }
        }
    }

    private func getCurrentIndex(for room: LaundryRoom) -> IndexPath? {
        if let section = currentSort.firstIndex(where: { (building) -> Bool in
            return building == room.building
        }), let rooms = currentResults[room.building] {
            if let row = rooms.firstIndex(of: room) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }

    fileprivate func attemptToLoadDictionary() {
        showActivity()
        LaundryAPIService.instance.loadIds { (success) in
            DispatchQueue.main.async {
                self.hideActivity()
                if !success {
                    self.delegate?.handleFailureToLoadDictionary()
                    return
                }

                self.setupDictionaries()
                self.setupCurrentSort()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: Functions implementing TableView
extension RoomSelectionView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return currentResults.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = currentSort[section]
        return currentResults[key]!.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentSort[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        let key = currentSort[indexPath.section]
        let room = currentResults[key]![indexPath.row]
        cell.textLabel?.text = room.name
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        if chosenRooms.contains(room) {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .labelPrimary
        } else {
            cell.textLabel?.textColor = chosenRooms.count == maxNumRooms ? .grey3 : .labelPrimary
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return chosenRooms.count < maxNumRooms ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = currentSort[indexPath.section]
        let room = currentResults[key]![indexPath.row]
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        chosenRooms.append(room)

        if chosenRooms.count == maxNumRooms {
            tableView.reloadData()
            selectChosenRooms()
        }

        delegate?.updateSelectedRooms(for: chosenRooms)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let key = currentSort[indexPath.section]
        let room = currentResults[key]![indexPath.row]
        if let index = chosenRooms.firstIndex(of: room) {
            chosenRooms.remove(at: index)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }

        if chosenRooms.count == maxNumRooms - 1 {
            tableView.reloadData()
            selectChosenRooms()
        }
        delegate?.updateSelectedRooms(for: chosenRooms)
    }

    // Resigns the keyboard if up once the user starts to scroll through the listings
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: Functions implementing SearchBar
extension RoomSelectionView: UISearchBarDelegate, UISearchDisplayDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            currentResults = buildings
            currentSort = sortHeaders(for: Array(buildings.keys))
            self.showEmptyViewIfNeeded()
            tableView.reloadData()
            selectChosenRooms()
            return
        }

        currentResults = [String: [LaundryRoom]]()
        for (building, laundryRooms) in buildings {
            if building.lowercased().contains(searchText.lowercased()) {
                currentResults[building] = laundryRooms
            } else {
                var toAdd: [LaundryRoom]  = []
                for room in laundryRooms {
                    if room.name.lowercased().contains(searchText.lowercased()) {
                        toAdd.append(room)
                    }
                }
                if !toAdd.isEmpty {
                    currentResults[building] = toAdd
                }
            }
        }
        currentSort = sortHeaders(for: Array(currentResults.keys))
        self.showEmptyViewIfNeeded()
        tableView.reloadData()
        selectChosenRooms()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }

}

// MARK: Functions implementing EmptyView
extension RoomSelectionView {
    internal func showEmptyViewIfNeeded() {
        emptyView.isHidden = !currentResults.isEmpty
        tableView.isHidden = currentResults.isEmpty
    }
}

extension RoomSelectionView {
    override func resignFirstResponder() -> Bool {
        return searchBar.resignFirstResponder()
    }
}
