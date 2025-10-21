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
final class LaundryViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var laundryHallIds: ResultWithLoading<[LaundryHallId]> = .loading
    @Published var hallUsages: [Int: ResultWithLoading<LaundryHallUsage>] = [:] // key: hall_id
    @Published var selectedHalls: Set<Int> = []
    
    // MARK: - AppStorage
    @AppStorage("selectedLaundryHallIds") private var selectedHallsData: Data = Data()
    
    // MARK: - Constants
    let maxSelection: Int = 3
    
    // MARK: - Initialization
    init() {
        loadSelectedHalls()
    }
    
    // MARK: - Laundry Halls Fetching
    func loadLaundryHalls() async {
        laundryHallIds = .loading
        do {
            let halls = try await LaundryAPIService.getLaundryHallIdData()
            laundryHallIds = .success(halls)
        } catch {
            laundryHallIds = .failure(error)
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
    
    // MARK: - Selection Management
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
    
    func isSelected(_ hallId: Int) -> Bool {
        selectedHalls.contains(hallId)
    }
    
    func canSelectMore(_ tempSelection: Set<Int>) -> Bool {
        tempSelection.count < maxSelection
    }
    
    func currentSelectedHalls() -> Set<Int> {
        selectedHalls
    }
    
    // MARK: - Persistence
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
