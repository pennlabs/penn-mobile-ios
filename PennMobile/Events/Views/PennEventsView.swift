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
    
    private var categories: [String] {
        viewModel.uniqueEventTypes
    }

    var body: some View {
//        NavigationView {
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
                        ForEach(viewModel.selectedCategory == "All" ? viewModel.events : viewModel.events.filter { $0.eventType == viewModel.selectedCategory }, id: \.id) { event in
                            NavigationLink(destination: PennEventsViewerView(event: event)) {
                                PennEventCellView(viewModel: event)
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchEvents()
            }
//        }
    }

}

struct PennEventsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEvents = [
            PennEvent(
                eventType: "Lecture",
                name: "Lecture Series: Jews and the University",
                description: "The integration of Jews into the university is one of the great success stories of modern American culture and Jewish life.",
                location: "The Katz Center for Judaic Studies",
                imageUrl: "https://penntoday.upenn.edu/sites/default/files/styles/event_large/public/2024-01/katz-center-teaser.jpg?h=733e6470&itok=kKJdQofY",
                start: "2024-03-23T18:45:00-04:00",
                end: "2024-03-14T16:00:00-04:00",
                email: "info@katzcenter.upenn.edu",
                website: "https://penntoday.upenn.edu/events/lecture-series-jews-and-university"
            )
        ]
        
        let categorizedEventType = "Penn Today"
        let viewModelEvents = sampleEvents.map { PennEventViewModel(from: $0, categorizedEventType: categorizedEventType) }
        let viewModel = PennEventsViewModel()
        viewModel.events = viewModelEvents

        return PennEventsView(viewModel: viewModel)
    }
}
