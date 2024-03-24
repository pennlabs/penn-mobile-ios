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
        PennEventCellView(viewModel: PennEventViewModel(
            id: "1",
            title: "Lecture Series: Jews and the University",
            description: "This free lecture series is an effort to share insights from history, sociology, education studies, and other fields that can help put the present moment into context.",
            imageUrl: "https://penntoday.upenn.edu/sites/default/files/styles/event_large/public/2024-01/katz-center-teaser.jpg?h=733e6470&itok=kKJdQofY",
            location: "The Katz Center for Judaic Studies",
            start: "01/23/2024",
            end: "03/14/2024",
            startTime: "6:45PM",
            endTime: "4:00PM", 
            link: "https://penntoday.upenn.edu/events/lecture-series-jews-and-university"
        ))
        .previewLayout(.sizeThatFits)
    }
}
