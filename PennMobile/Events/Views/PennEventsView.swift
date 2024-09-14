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
                ForEach(viewModel.uniqueEventTypes, id: \.self) { category in
                    Text(category).tag(category)
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
        if viewModel.selectedCategory == "All" {
            return viewModel.events
        } else {
            return viewModel.events.filter { $0.categorizedEventType == viewModel.selectedCategory }
        }
    }
}

#Preview {
    PennEventsView()
}

