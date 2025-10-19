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
    
    @Published var laundryHallIds: ResultWithLoading<[LaundryHallId]> = .loading
    @Published var hallUsages: [Int: ResultWithLoading<LaundryHallUsage>] = [:] // key: hall_id
    
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
}
