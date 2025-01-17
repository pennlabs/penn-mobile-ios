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
import Kingfisher

struct PennEventsViewerView: View {
    var event: PennEvent
    
    @Environment(\.dismiss) private var dismiss
    
    // boolean flags for the webView and link button
    @State private var showingWebView = false
    @State private var showAlert = false
    
    // for email button
    @State private var showingMailComposer = false
    
    // coordinates for the map annotation
    @State private var eventCoordinate: CLLocationCoordinate2D?
    
    // for is virtual event
    @State private var isVirtualEvent = false
    
    // default to philly
    @State private var region = PennLocation.defaultRegion
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack {
                    GeometryReader { geometry in
                        AsyncImage(url: event.imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 250)
                                .clipped()
                        } placeholder: {
                            Image("pennmobile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 250)
                                .clipped()
                        }
                    }
                    .frame(height: 250)
                    
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
                            Text(event.eventTitle)
                                .font(.system(size: 25))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .lineLimit(3)
                            
                            Spacer()
                            
                        }
                        HStack {
                            Text(event.eventLocation)
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
                        Text("\(event.formattedStartDate)")
                            .font(.subheadline)
                        Text("\(event.formattedStartTime)")
                            .font(.subheadline)
                            .fontWeight(.thin)
                    }
                    HStack {
                        Text("Event End:")
                            .font(.headline)
                        Text("\(event.formattedEndDate)")
                            .font(.subheadline)
                        Text("\(event.formattedEndTime)")
                            .font(.subheadline)
                            .fontWeight(.thin)
                    }
                }
                .padding(.leading)
                .padding(.top, 4)
                
                // description
                Text(event.eventDescription)
                    .padding([.leading, .trailing])
                    .padding(.top, 5)
                    .font(.system(size: 18))
                    .fontWeight(.thin)
                    .padding(.bottom)
                
                
                // map
                if let coordinate = eventCoordinate {
                    Map(coordinateRegion: $region, annotationItems: [coordinate]) { location in
                        MapAnnotation(coordinate: location) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .cornerRadius(15)
                    .frame(height: 250)
                    .padding(.horizontal, 20)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 5, y: 5)
                } else if isVirtualEvent {
                    Text("This event is virtual and will be held online.")
                        .font(.headline)
                        .padding()
                }
                // for events with no location but not virtual
                else {
                     Text("Location not available.")
                         .font(.headline)
                         .padding()
                }
                
                // buttons
                HStack {
                    Spacer()
                    
                    // more info link button
                    Button(action: {
                        if !event.eventLink.isEmpty {
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
                        .background(!event.eventLink.isEmpty ? Color.black : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(event.eventLink.isEmpty)
                    .sheet(isPresented: $showingWebView) {
                        if let url = URL(string: event.eventLink) {
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
                            print("Cannot send mail")
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Contact")
                        }
                        .padding()
                        .background(!event.eventContactInfo.isEmpty ? Color.black : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(event.eventContactInfo.isEmpty)
                    .sheet(isPresented: $showingMailComposer) {
                        MailComposeView(isShowing: $showingMailComposer, email: event.eventContactInfo)
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
            dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.white)
        })
        .onAppear {
            let result = PennLocation.coordinateForEvent(
                location: event.eventLocation,
                eventName: event.eventTitle,
                eventType: event.eventType.displayName
            )

            eventCoordinate = result.coordinate
            if let coordinate = result.coordinate {
                region.center = coordinate
            }

            isVirtualEvent = result.isVirtual
        }
    }
}


#Preview {
    PennEventsViewerView(event: PennEvent())
}
