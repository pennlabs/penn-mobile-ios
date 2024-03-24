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
    @Published var start: String
    @Published var end: String
    @Published var startTime: String
    @Published var endTime: String
    @Published var link: String
    
    init(id: String, title: String, description: String, imageUrl: String, location: String, start: String, end: String, startTime: String, endTime: String, link: String) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = URL(string: imageUrl)
        self.location = location
        self.start = start
        self.end = end
        self.startTime = startTime
        self.endTime = endTime
        self.link = link
    }
}

