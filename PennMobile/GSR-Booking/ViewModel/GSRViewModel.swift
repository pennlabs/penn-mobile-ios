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
    func fetchData()
    func resetDataForCell(at indexPath: IndexPath)
}

class GSRViewModel: NSObject {

    // MARK: Dates + Locations
    fileprivate var dates = GSRDateHandler.generateDates()
    fileprivate let locations = GSRLocationModel.shared.getLocations()
    fileprivate lazy var selectedDate = self.dates[0]
//    fileprivate lazy var selectedLocation = self.locations[0]
    fileprivate var selectedLocation: GSRLocation

    // MARK: Room Data
    fileprivate var allRooms = [GSRRoom]()
    fileprivate var filteredRooms = [GSRRoom]()

    // MARK: Current Selection
    fileprivate var selectedRoomId: Int?

    // MARK: Delegate
    var delegate: GSRViewModelDelegate!

    init(selectedLocation: GSRLocation) {
        self.selectedLocation = selectedLocation
    }

    // MARK: Empty 
    var isEmpty: Bool {
        get {
            return filteredRooms.isEmpty
        }
    }

    var group: GSRGroup?
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
            if row == 0 {
                return "Today"
            } else if row == 1 {
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
        return filteredRooms.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredRooms[section].roomName
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.identifier, for: indexPath) as! RoomCell
        cell.room = filteredRooms[indexPath.section]
        cell.contentView.isUserInteractionEnabled = false
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
        var populatedRooms = rooms

        let (minDate, maxDate) = rooms.getMinMaxDates()

        if let minDate = minDate, let maxDate = maxDate {
            populatedRooms = rooms.map({ return GSRRoom(roomName: $0.roomName, id: $0.id, availability: $0.addMissingTimeslots(minDate: minDate, maxDate: maxDate))})
        }

        allRooms = populatedRooms
        filteredRooms = populatedRooms
        selectedRoomId = nil
    }

    func updateDates() {
        dates = GSRDateHandler.generateDates()
    }
}

// MARK: Selection Delegate
extension GSRViewModel: GSRSelectionDelegate {

    func handleSelection(for id: Int) {
        if selectedRoomId != nil && selectedRoomId != id {
            let roomCell = filteredRooms.firstIndex(where: {$0.id == selectedRoomId})!
            // There is only one row per section (room)
            delegate.resetDataForCell(at: IndexPath(item: 0, section: roomCell))
        }

        selectedRoomId = id
    }

    func existsTimeSlot() -> Bool {
        let roomsWithTimeSlots = allRooms.filter { $0.availability.count > 0 }
        return roomsWithTimeSlots.count > 0
    }
}

// MARK: - GSRRangeSliderDelegate
extension GSRViewModel: GSRRangeSliderDelegate {
    func existsNonEmptyRoom() -> Bool {
        return !allRooms.isEmpty
    }

    func updateCurrentRooms(startDate: Date, endDate: Date) {
        var currentRooms = [GSRRoom]()
        for room in allRooms {
            let timeSlots = room.availability.filter {
                return $0.startTime >= startDate && $0.endTime <= endDate
            }

            var filteredRoom = room
            filteredRoom.availability = timeSlots
            if !timeSlots.isEmpty {
                currentRooms.append(filteredRoom)
            }
        }
        self.filteredRooms = currentRooms
    }

    func parseData(startDate: Date, endDate: Date) {
        if let minDate = getMinDate(), startDate < minDate {
            // Start date is by hour but minDate is by half-hour
            // So start date may be less than the minDate
            updateCurrentRooms(startDate: minDate, endDate: endDate)
        } else {
            updateCurrentRooms(startDate: startDate, endDate: endDate)
        }
        delegate.refreshDataUI()
    }

    // If today, return current time. Otherwise, return earliest available time
    func getMinDate() -> Date? {
        if selectedDate.day == dates[0].day {
            return Date().roundedDownToHalfHour
        } else {
            return allRooms.getMinMaxDates().0
        }
    }

    func getMaxDate() -> Date? {
        return allRooms.getMinMaxDates().1
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

    func getSelectedRoomId() -> Int? {
        return selectedRoomId
    }

    func getSelectRoomName() -> String? {
        if let selectedRoomId = getSelectedRoomId() {
            return filteredRooms.first(where: {$0.id == selectedRoomId})?.roomName
        }

        return nil
    }

    func getSelectedRoomIdIndexPath() -> IndexPath? {
        if let selectedRoomId = selectedRoomId, let index = filteredRooms.firstIndex(where: {$0.id == selectedRoomId}) {
            return IndexPath(item: 0, section: index)
        }

        return nil
    }
}

// MARK: - Select Location
extension GSRViewModel {
    func getLocationIndex(_ location: GSRLocation) -> Int {
        return locations.firstIndex(of: location)!
    }
}
