//
//  LaundryViewModel.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import PennMobileShared
import SwiftUI

@MainActor
class LaundryViewModel: ObservableObject {
    
    @Published var laundryHallIds: ResultWithLoading<[LaundryHallInfo]> = .loading
    @Published var hallUsages: [Int: ResultWithLoading<LaundryHallUsageResponse>] = [:] // key: hallId
    @Published var selectedHalls: Set<Int> = [] {
        didSet {
            Task {
                await self.loadSelectedLaundryHallUsage()
            }
        }
    }
    @Published var alarmHandler: LaundryAlarmHandler = LaundryAlarmService.makeHandler()
    
    
    @AppStorage("selectedLaundryHallIds") private var selectedHallsData: Data = Data()
    
    let maxSelection: Int = 3
    
    init() {
        loadSelectedHalls()
        alarmHandler.fetchAlarms()
    }
    
    func toggleMachineAlarm(machine: MachineDetail, hallName: String) {
        if (machine.status == .inUse) {
            if isAlarmActive(for: machine) {
                alarmHandler.unsubscribe(from: machine)
            } else {
                alarmHandler.subscribe(to: machine, and: hallName)
            }
        }
    }
    
    func isAlarmActive(for machine: MachineDetail) -> Bool {
        guard #available(iOS 26.0, *),
              let handler = alarmHandler as? AlarmKitAlarmHandler else {
            return false
        }
        
        return handler.containsAlarm(for: machine.id)
    }
    
    func loadLaundryHalls() async {
        laundryHallIds = .loading
        do {
            let halls = try await LaundryAPIService.getLaundryHallIdData()
            laundryHallIds = .success(halls)
        } catch {
            laundryHallIds = .failure(error)
        }
    }
    
    func loadSelectedLaundryHallUsage() async {
        for hallId in selectedHalls {
            await loadLaundryHallUsage(for: hallId)
        }
    }
    
    func loadLaundryHallUsage(for hallId: Int) async {
        hallUsages[hallId] = .loading
        do {
            let usage = try await LaundryAPIService.getLaundryHallUsage(for: hallId)
            hallUsages[hallId] = .success(usage)
        } catch {
            hallUsages[hallId] = .failure(error)
        }
    }
    
    func toggleSelection(_ hallId: Int) {
        if selectedHalls.contains(hallId) {
            selectedHalls.remove(hallId)
        } else if canSelectMore(selectedHalls) {
            selectedHalls.insert(hallId)
        }
        saveSelectedHalls()
    }
    
    func setSelectedHalls(_ halls: Set<Int>) {
        selectedHalls = halls
        saveSelectedHalls()
    }
    
    func removeSelectedHall(_ hallId: Int) {
        selectedHalls.remove(hallId)
        saveSelectedHalls()
    }
    
    func isSelected(_ hallId: Int) -> Bool {
        selectedHalls.contains(hallId)
    }
    
    func canSelectMore(_ tempSelection: Set<Int>) -> Bool {
        tempSelection.count < maxSelection
    }
    
    func currentSelectedHalls() -> Set<Int> {
        selectedHalls
    }
    
    private func saveSelectedHalls() {
        if let encoded = try? JSONEncoder().encode(Array(selectedHalls)) {
            selectedHallsData = encoded
        }
    }
    
    private func loadSelectedHalls() {
        if let decoded = try? JSONDecoder().decode([Int].self, from: selectedHallsData) {
            selectedHalls = Set(decoded)
        }
    }
}
