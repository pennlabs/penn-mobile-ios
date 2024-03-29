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
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.events, id: \.id) { eventViewModel in
                            NavigationLink(destination: PennEventsViewerView(event: eventViewModel)) {
                                PennEventCellView(viewModel: eventViewModel)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 3)
                        }
                    }
                }
                .onAppear {
                    // fetch events into array from backend
                    viewModel.fetchEvents()
                }
                
            }
        }

    }
}

class PennEventsViewModel: ObservableObject {
    @Published var events: [PennEventViewModel] = []

    func fetchEvents() {
        PennEventsAPIManager.shared.fetchEvents { [weak self] (pennEvents, error) in
            DispatchQueue.main.async {
                if let pennEvents = pennEvents {
                    self?.events = pennEvents.map(PennEventViewModel.init)
                } else if let error = error {
                    print("error fetching events: \(error.localizedDescription)")
                }
            }
        }
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
        
        let viewModel = PennEventsViewModel()
        viewModel.events = sampleEvents.map(PennEventViewModel.init)
           
        return PennEventsView(viewModel: viewModel)
    }
}
