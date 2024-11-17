//
//  PennEventsView.swift
//  PennMobile
//
//  Created by Jacky on 3/10/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct PennEventsView: View {
    @StateObject var viewModel = PennEventsViewModel()
    
    var body: some View {
        VStack {
            Picker("Select Category", selection: $viewModel.selectedCategory) {
                Text("All").tag(nil as EventType?)
                ForEach(viewModel.uniqueEventTypes, id: \.self) { category in
                    Text(category.displayName).tag(Optional(category))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            ScrollView {
                LazyVStack {
                    ForEach(filteredEvents, id: \.id) { event in
                        NavigationLink(destination: PennEventsViewerView(event: event)) {
                            PennEventCellView(event: event)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchEvents()
        }
    }
    
    private var filteredEvents: [PennEvent] {
        if let selectedCategory = viewModel.selectedCategory {
            return viewModel.events.filter { $0.eventType == selectedCategory }
        } else {
            return viewModel.events
        }
    }
}

#Preview {
    PennEventsView()
}

