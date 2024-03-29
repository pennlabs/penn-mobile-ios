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
    @Published var events: [PennEventViewModel] = []
    @Published var selectedCategory: String = "All"

    var uniqueEventTypes: [String] {
        var types = events.map { $0.eventType }
        types = Array(Set(types)).sorted()
        // All is default category
        types.insert("All", at: 0)
        return types
    }

    func fetchEvents() {
        PennEventsAPIManager.shared.fetchEvents { [weak self] pennEvents, error in
            DispatchQueue.main.async {
                if let pennEvents = pennEvents {
                    // preprocess and map PennEvent to PennEventViewModel
                    self?.events = pennEvents.map { event -> PennEventViewModel in
                        var modifiedEvent = event
                        modifiedEvent.eventType = self?.categorizeEventType(eventType: event.eventType!) ?? "General"
                        return PennEventViewModel(from: modifiedEvent)
                    }
                } else if let error = error {
                    print("error fetching events: \(error.localizedDescription)")
                }
            }
        }
    }

    // group into categories
    private func categorizeEventType(eventType: String) -> String {
        if eventType.contains("COLLEGE HOUSE") {
            return "Houses"
        } else if eventType.contains("ENGINEERING") {
            return "Engineering"
        } else if eventType.contains("WHARTON") {
            return "Wharton"
        } else if eventType.contains("PENN TODAY") {
            return "Penn Today"
        } else if eventType.contains("VENTURE LAB") {
            return "Venture Lab"
        }
        
        return eventType
    }
}
