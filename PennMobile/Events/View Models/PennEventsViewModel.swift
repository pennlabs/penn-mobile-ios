//
//  PennEventsViewModel.swift
//  PennMobile
//
//  Created by Jacky on 3/29/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

// this class handles all the EVENTS based on the PennEVENTViewModel

class PennEventsViewModel: ObservableObject {
    @Published var events: [PennEvent] = []
    @Published var selectedCategory: String = "All"
    
    var uniqueEventTypes: [String] {
        var types = events.map { $0.categorizedEventType }
        types = Array(Set(types)).sorted()
        
        types.insert("All", at: 0)
        return types
    }
    
    func fetchEvents() async {
        do {
            let pennEvents = try await PennEventsAPIManager.shared.fetchAllEvents()
            self.events = pennEvents
        } catch {
            print("Error fetching events: \(error.localizedDescription)")
        }
    }
    
}
