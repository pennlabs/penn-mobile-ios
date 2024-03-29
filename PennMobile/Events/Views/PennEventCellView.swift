//
//  PennEventCellView.swift
//  PennMobile
//
//  Created by Jacky on 3/3/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct PennEventCellView: View {
    @ObservedObject var viewModel: PennEventViewModel
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            if let imageUrl = viewModel.imageUrl {
                AsyncImage(url: imageUrl) { phase in
                    if let image = phase.image {
                        image.resizable()
                             .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Image("pennmobile")                             
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: screenWidth - 30, height: 190)
                .cornerRadius(10)
                .clipped()
            } else {
                Image("pennmobile")
                     .resizable()
                     .aspectRatio(contentMode: .fill)
                     .frame(width: screenWidth - 30, height: 190)
                     .cornerRadius(10)
                     .clipped()
            }

            // gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(10)

            // text
            VStack {
                Spacer()
                HStack {
                    Text(viewModel.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                }
                HStack {
                    Text(viewModel.location)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
            .padding()
        }
        .frame(width: screenWidth - 30, height: 190)
        .cornerRadius(10)
        .padding(.horizontal, 30)
        .shadow(radius: 10)
    }
}

struct PennEventCellView_Previews: PreviewProvider {
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
