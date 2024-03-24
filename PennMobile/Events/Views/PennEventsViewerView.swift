//
//  PennEventsViewerView.swift
//  PennMobile
//
//  Created by Jacky on 3/10/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit
import SafariServices

struct PennEventsViewerView: View {
    var event: PennEventViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    // boolean flags for the webView and link button
    @State private var showingWebView = false
    @State private var showAlert = false
    
    // default to philly
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // placeholder function to simulate fetching coordinates based on a location name (backend??)
    func fetchCoordinates(for location: String) {
        // have a simulated delay and then set region to the location's coordinates
        let simulatedCoordinates = CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932)
        region.center = simulatedCoordinates
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack {
                    AsyncImage(url: event.imageUrl) { image in
                        image.resizable()
                    } placeholder: {
                        Image("pennmobile")
                             .resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(height: 250)
                             .clipped()                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                    
                    // gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // text
                    VStack {
                        Spacer()
                        HStack {
                            Text(event.title)
                                .font(.system(size: 25))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Spacer()
                            
                        }
                        HStack {
                            Text(event.location)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                    .padding()
                }
                
                // times
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Event Start:")
                            .font(.headline)
                        Text("\(event.start)")
                            .font(.subheadline)
                        Text("\(event.startTime)")
                            .font(.subheadline)
                            .fontWeight(.thin)
                    }
                    HStack {
                        Text("Event End:")
                            .font(.headline)
                        Text("\(event.end)")
                            .font(.subheadline)
                        Text("\(event.endTime)")
                            .font(.subheadline)
                            .fontWeight(.thin)
                    }
                }
                .padding(.leading)
                .padding(.top, 4)
                
                // description
                Text(event.description)
                    .padding([.leading, .trailing])
                    .padding(.top, 5)
                    .font(.system(size: 18))
                    .fontWeight(.thin)
                    .padding(.bottom)

                // map
                Map(coordinateRegion: $region, showsUserLocation: true)
                    .cornerRadius(15)
                    .frame(height: 250)
                    .disabled(true)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .shadow(color: .gray, radius: 5, x: 5, y: 5)
                    .onAppear {
                        // fetching the coordinates based on location name (backend?)
                        fetchCoordinates(for: event.location)
                    }
                
                // more info link button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if event.link != "" {
                            self.showingWebView = true
                        } else {
                            self.showAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("More Info")
                        }
                        .padding()
                        .background(event.link != "" ? Color.black : Color.grey4)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(event.link == "")
                    .sheet(isPresented: $showingWebView) {
                        if let url = URL(string: event.link) {
                            SafariView(url: url)
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("No valid link"), message: Text("This event does not have a link provided."), dismissButton: .default(Text("OK")))
                    }
                    
                    Spacer()
                }
                .padding()
                .shadow(radius: 10)
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            // changes back button to white arrow
            Image(systemName: "arrow.left")
                .foregroundColor(.white)
        })
    }
}

//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//    
//    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
//        return SFSafariViewController(url: url)
//    }
//    
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
//    }
//}

struct PennEventsViewerView_Previews: PreviewProvider {
    static var previews: some View {
        PennEventsViewerView(event: PennEventViewModel(
            id: "1",
            title: "Lecture Series: Jews and the University",
            description: "This free lecture series is an effort to share insights from history, sociology, education studies, and other fields that can help put the present moment into context",
            imageUrl: "https://penntoday.upenn.edu/sites/default/files/styles/event_large/public/2024-01/katz-center-teaser.jpg?h=733e6470&itok=kKJdQofY",
            location: "The Katz Center for Judaic Studies",
            start: "01/23/2024",
            end: "03/14/2024",
            startTime: "6:45PM",
            endTime: "4:00PM",
            link: "https://penntoday.upenn.edu/events/lecture-series-jews-and-university"
        ))
    }
}
