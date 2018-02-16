//
//  GSRViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

enum SelectionType {
    case remove, add
}

enum GSRState {
    case loggedOut
    case loggedIn
    case readyToSubmit(GSRBooking)
}

protocol GSRViewModelDelegate: ShowsAlert {
    func refreshDataUI()
    func refreshSelectionUI()
    func fetchData()
}

class GSRViewModel: NSObject {
    
    // MARK: Dates + Locations
    fileprivate var dates = GSRDateHandler.generateDates()
    fileprivate let locations = GSRLocationModel.shared.getLocations()
    fileprivate lazy var selectedDate = self.dates[0]
    fileprivate lazy var selectedLocation = self.locations[0]
    
    // MARK: Room Data
    fileprivate var allRooms = [GSRRoom]()
    fileprivate var currentRooms = [GSRRoom]()
    
    // MARK: Current Selection
    fileprivate var currentSelection = [GSRTimeSlot]()
    
    // MARK: Delegate
    var delegate: GSRViewModelDelegate!
    
    // MARK: GSR State
    var state: GSRState {
        get {
            if let booking = getBooking() {
                return .readyToSubmit(booking)
            } else {
                return GSRUser.hasSavedUser() ? .loggedIn : .loggedOut
            }
        }
    }
    
    // MARK: Empty 
    var isEmpty: Bool {
        get {
            return currentRooms.isEmpty
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension GSRViewModel: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? dates.count : locations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedDate = dates[row]
        } else if component == 1 {
            selectedLocation = locations[row]
        }
        delegate!.fetchData()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            if (row == 0) {
                return "Today"
            } else if (row == 1) {
                return "Tomorrow"
            }
            return dates[row].dayOfWeek
        } else {
            return locations[row].name
        }
    }
}

// MARK: - UITableViewDataSource
extension GSRViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentRooms.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentRooms[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.identifier, for: indexPath) as! RoomCell
        cell.room = currentRooms[indexPath.section]
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GSRViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RoomCell.cellHeight
    }
}

// MARK: - Reload Data
extension GSRViewModel {
    func updateData(with rooms: [GSRRoom]) {
        var rooms = rooms
        if let gid = selectedLocation.gid {
            rooms = rooms.filter { $0.gid == gid }
        }
        self.allRooms = rooms
        self.currentRooms = rooms
        self.currentSelection = []
    }
    
    func updateDates() {
        dates = GSRDateHandler.generateDates()
    }
}

// MARK: Selection Delegate
extension GSRViewModel: GSRSelectionDelegate {
    func containsTimeSlot(_ timeSlot: GSRTimeSlot) -> Bool {
        return currentSelection.contains(timeSlot)
    }
    
    func validateChoice(for room: GSRRoom, timeSlot: GSRTimeSlot, action: SelectionType) -> Bool {
        switch action {
        case .add:
            return validateAddition(timeSlot)
        case .remove:
            return validateRemoval(timeSlot)
        }
    }
    
    private func validateAddition(_ timeSlot: GSRTimeSlot) -> Bool {
        if currentSelection.count >= 4 {
            return false
        } else if currentSelection.count == 0 {
            return true
        }
        
        var flag = false
        for selection in currentSelection {
            flag = flag || timeSlot == selection.prev || timeSlot == selection.next
        }
        return flag
    }
    
    private func validateRemoval(_ timeSlot: GSRTimeSlot) -> Bool {
        if !currentSelection.contains(timeSlot) {
            return false
        } else if let prev = timeSlot.prev, let next = timeSlot.next,
            currentSelection.contains(prev) && currentSelection.contains(next) {
            return false
        }
        return true
    }
    
    func handleSelection(for room: GSRRoom, timeSlot: GSRTimeSlot, action: SelectionType) {
        switch action {
        case .add:
            currentSelection.append(timeSlot)
            break
        case .remove:
            currentSelection.remove(at: currentSelection.index(of: timeSlot)!)
            break
        }
        
        if currentSelection.count == 0 || (currentSelection.count == 1 && action == .add) {
            delegate.refreshSelectionUI()
        }
    }
}

// MARK: - GSRRangeSliderDelegate
extension GSRViewModel: GSRRangeSliderDelegate {
    func existsNonEmptyRoom() -> Bool {
        return !allRooms.isEmpty
    }
    
    func parseData(startDate: Date, endDate: Date) {
        var currentRooms = [GSRRoom]()
        for room in allRooms {
            let timeSlots = room.timeSlots.filter {
                return $0.startTime >= startDate && $0.endTime <= endDate
            }
            if !timeSlots.isEmpty {
                let newRoom = GSRRoom(name: room.name, roomId: room.roomId, gid: room.gid, imageUrl: room.imageUrl, capacity: room.capacity, timeSlots: timeSlots)
                currentRooms.append(newRoom)
            }
        }
        self.currentRooms = currentRooms.sorted()
        delegate.refreshDataUI()
    }
    
    func getMinDate() -> Date {
        return allRooms.getMinMaxDates(day: selectedDate).0
    }
    
    func getMaxDate() -> Date {
        return allRooms.getMinMaxDates(day: selectedDate).1
    }
}

// MARK: - Data Getter Methods
extension GSRViewModel {
    func getSelectedLocation() -> GSRLocation {
        return selectedLocation
    }
    
    func getSelectedDate() -> GSRDate {
        return selectedDate
    }
    
    fileprivate func getBooking() -> GSRBooking? {
        if currentSelection.isEmpty {
            return nil
        }
        let roomId = currentSelection[0].roomId
        let startTime: Date
        let endTime: Date
        var timeSlot = currentSelection[0]
        while timeSlot.prev != nil && currentSelection.contains(timeSlot.prev!) {
            timeSlot = timeSlot.prev!
        }
        startTime = timeSlot.startTime
        while timeSlot.next != nil && currentSelection.contains(timeSlot.next!) {
            timeSlot = timeSlot.next!
        }
        endTime = timeSlot.endTime
        return GSRBooking(location: selectedLocation, roomId: roomId, start: startTime, end: endTime)
    }
}
