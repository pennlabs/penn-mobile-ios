//
//  RefactorDiningViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation
import SwiftUI


class RefactorDiningViewModel: ObservableObject {
    
    @Published var diningHalls: [RefactorDiningHall]
    @Published var retailDining: [RefactorDiningHall]
    
    var allDiningHalls: [RefactorDiningHall] {
        didSet {
            diningHalls = allDiningHalls.filter({$0.venueType == .dining})
            retailDining = allDiningHalls.filter({$0.venueType == .retail})
        }
    }
    
    init() {
        allDiningHalls = []
        diningHalls = []
        retailDining = []
    }
    
    func refresh() async {
        //eventually get cached data prior to fetch
            if case .success(let halls) = await RefactorDiningAPI.instance.getDiningHalls() {
                allDiningHalls = halls
            } else {
                allDiningHalls = []
            }
    }
    
    
    
    
    
}
