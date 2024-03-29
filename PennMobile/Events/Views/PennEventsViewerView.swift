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
import MessageUI

struct PennEventsViewerView: View {
    var event: PennEventViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    // boolean flags for the webView and link button
    @State private var showingWebView = false
    @State private var showAlert = false
    
    // for email button
    @State private var showingMailComposer = false
    
    // default to philly
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932),
        span: MKCoordinateSpan(latitudeDelta: 0.0020, longitudeDelta: 0.0020)
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
                         Text("\(event.startDate)")
                             .font(.subheadline)
                         Text("\(event.startTime)")
                             .font(.subheadline)
                             .fontWeight(.thin)
                     }
                     HStack {
                         Text("Event End:")
                             .font(.headline)
                         Text("\(event.endDate)")
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
//                 if event.location != "No Location" {
                     Map(coordinateRegion: $region, annotationItems: [event]) { event in
                         MapAnnotation(coordinate: region.center) {
                             Image(systemName: "mappin.circle.fill")
                                 .foregroundColor(.red)
                                 .onTapGesture {
                                     print("Tapped on location: \(event.location)")
                                 }
                         }
                     }
                     .cornerRadius(15)
                     .frame(height: 250)
                     .disabled(true)
                     .padding(.leading, 20)
                     .padding(.trailing, 20)
                     .shadow(color: .gray, radius: 5, x: 5, y: 5)
                     .onAppear {
                         if let coordinates = PennEventLocation.coordinateForEvent(location: event.location, eventName: event.title, eventType: event.originalEventType) {
                             print("fetched coordinates for \(event.location) AND \(event.title) AND \(event.originalEventType): \(coordinates)")
                             region.center = coordinates
                         } else {
                             print("default for \(event.location)")
                         }
                     }
//                 }
                 
                 // buttons
                 HStack {
                     Spacer()
                     
                     // more info link button
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
                     
                     // email Button
                     Button(action: {
                         if MFMailComposeViewController.canSendMail() {
                              self.showingMailComposer = true
                          } else {
                              print("cannot send mail")
                          }
                     }) {
                         HStack {
                             Image(systemName: "envelope")
                             Text("Contact")
                         }
                     }
                     .padding()
                     .background(event.contactInfo != "" ? Color.black : Color.gray)
                     .foregroundColor(.white)
                     .cornerRadius(15)
                     .disabled(event.contactInfo == "")
                     .sheet(isPresented: $showingMailComposer) {
                         MailComposeView(isShowing: $showingMailComposer, email: event.contactInfo)
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


struct PennEventsViewerView_Previews: PreviewProvider {
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
