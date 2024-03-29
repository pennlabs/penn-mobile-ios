//
//  PennEventViewModel.swift
//  PennMobile
//
//  Created by Jacky on 3/3/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

class PennEventViewModel: ObservableObject, Identifiable {
    @Published var id: String
    @Published var title: String
    @Published var description: String
    @Published var imageUrl: URL?
    @Published var location: String
    @Published var startDate: String
    @Published var endDate: String
    @Published var startTime: String
    @Published var endTime: String
    @Published var link: String
    @Published var contactInfo: String
    @Published var eventType: String
    @Published var originalEventType: String
    
    init(from pennEvent: PennEvent) {
        self.id = UUID().uuidString
        self.title = pennEvent.name ?? "No Title"
        self.description = pennEvent.description ?? "No Description"
        self.imageUrl = URL(string: pennEvent.imageUrl ?? "")
        self.location = pennEvent.location ?? "No Location"
        self.link = pennEvent.website ?? "No Link"
        self.contactInfo = pennEvent.email ?? "No Contact Info"
        self.originalEventType = pennEvent.eventType ?? "Unknown"
        self.eventType = pennEvent.eventType ?? "No Event Type"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        if let start = pennEvent.start, let startDate = dateFormatter.date(from: start) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            self.startDate = dateFormatter.string(from: startDate)
            dateFormatter.dateFormat = "h:mm a"
            self.startTime = dateFormatter.string(from: startDate)
        } else {
            self.startDate = "No Start Date"
            self.startTime = "No Start Time"
        }

        if let end = pennEvent.end, let endDate = dateFormatter.date(from: end) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            self.endDate = dateFormatter.string(from: endDate)
            dateFormatter.dateFormat = "h:mm a"
            self.endTime = dateFormatter.string(from: endDate)
        } else {
            self.endDate = "No End Date"
            self.endTime = "No End Time"
        }
    }
    
}

