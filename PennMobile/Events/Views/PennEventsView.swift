//
//  PennEventsView.swift
//  PennMobile
//
//  Created by Jacky on 3/10/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct PennEventsView: View {
    
    @State var events: [PennEventViewModel] = []

    var body: some View {
        NavigationView {
            VStack {
//                HStack {
//                    Text("Events")
//                        .font(.largeTitle)
//                        .fontWeight(.heavy)
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, -1)
//                    
//                    Spacer()
//                }
                
                ScrollView {
                    LazyVStack {
                        ForEach(events, id: \.id) { eventViewModel in
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
                }
                
            }
        }

    }
}

struct PennEventsView_Previews: PreviewProvider {
    static var previews: some View {
        PennEventsView(events: [
            PennEventViewModel(
                id: "1",
                title: "Lecture Series: Jews and the University",
                description: "The integration of Jews into the university is one of the great success stories of modern American culture and Jewish life. But recent events at Penn and at other campuses have led to accusations that the university has been too tolerant of antisemitism and become less welcoming to Jews. This free lecture series is an effort to share insights from history, sociology, education studies, and other fields that can help put the present moment into context. The series kicks off with Dara Horn’s in-person appearance at Penn Hillel on January 23, and continues with online talks through February and March. For more information, visit Lecture Series: Jews and the University",
                imageUrl: "https://penntoday.upenn.edu/sites/default/files/styles/event_large/public/2024-01/katz-center-teaser.jpg?h=733e6470&itok=kKJdQofY",
                location: "The Katz Center for Judaic Studies",
                start: "3/23/24",
                end: "3/14/24",
                startTime: "6:45 p.m",
                endTime: "4:00 p.m",
                link: "https://penntoday.upenn.edu/events/lecture-series-jews-and-university"
            ),
            PennEventViewModel(
                id: "2",
                title: "ICA Spring 2024 Exhibitions",
                description: "“Dominique White and Alberta Whittle: Sargasso Sea” and “Tomashi Jackson: Across the Universe” are presented as the Institute of Contemporary Art’s spring 2024 exhibitions. The former is an installation that draws inspiration from the Sargasso Sea, the only body of water defined by oceanic currents. The latter, meanwhile, brings together paintings, video, prints, and sculpture by Jackson, who investigates histories related to cities, lands, and individuals in the U.S.",
                imageUrl: "https://penntoday.upenn.edu/sites/default/files/styles/event_large/public/2024-01/Whittle_ICLA-1.jpg?h=8a57bed4&itok=PDzfp_T0",
                location: "Institute of Contemporary Art",
                start: "2/10/24",
                end: "6/2/24",
                startTime: "12:00 p.m",
                endTime: "6:00 p.m",
                link: "https://penntoday.upenn.edu/events/ica-spring-2024-exhibitions"
            ),
            PennEventViewModel(
                id: "3",
                title: "The Illuminated Body",
                description: "“Barbara Earl Thomas: The Illuminated Body” features the latest series of portraits by the artist. It is her Philadelphia debut and includes nine large-scale cut paper pieces that celebrate Black cultural icons such as August Wilson, Seth Parker Woods, and Charles Johnson, alongside Thomas’ friends, family, and acquaintances.",
                imageUrl: "https://penntoday.upenn.edu/sites/default/files/styles/event_large/public/2024-01/Girl_and_the_world-461x700_0.jpg?h=86826247&itok=6TOf-jFV",
                location: "Arthur Ross Gallery",
                start: "2/17/24",
                end: "5/21/24",
                startTime: "10:00 a.m",
                endTime: "5:00 p.m.",
                link: "https://penntoday.upenn.edu/events/illuminated-body"
            ),
            PennEventViewModel(
                id: "4",
                title: "No ImageURL, No Link Example",
                description: "Description for sample event 4",
                imageUrl: "",
                location: "Location",
                start: "Start Date",
                end: "End Date",
                startTime: "Start Time",
                endTime: "End Time",
                link: ""
            )
        ])

    }
}
