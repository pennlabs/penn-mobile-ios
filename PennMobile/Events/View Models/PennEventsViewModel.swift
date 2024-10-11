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
    @Published var selectedCategory: EventType?
    
    var uniqueEventTypes: [EventType] {
        var types = events.map { $0.eventType }
        types = Array(Set(types)).sorted { $0.displayName < $1.displayName }
        
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
