//
//  GSRShareDetailView.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import MapKit

struct GSRShareDetailView: View {
    let model: GSRShareModel
    @State private var showCalendarAlert = false

    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }

    private var timeFormatter: DateFormatter {
        let tf = DateFormatter()
        tf.timeStyle = .short
        return tf
    }

    struct Place: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1932),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )

    var body: some View {
        let roomName = /\[Me\]\s*(.*)/
        let splitRoom = model.reservation.roomName.split(separator: ":").first ?? ""
        let room = splitRoom.firstMatch(of: roomName)?.1
        let gsrLocation = model.reservation.gsr.name

        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                KFImage(URL(string: model.reservation.gsr.imageUrl))
                    .resizable()
                    .allowsHitTesting(false)
                
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.6), .black.opacity(0.2), .clear, .black.opacity(0.3), .black]), startPoint: .init(x: 0.5, y: 0.2), endPoint: .init(x: 0.5, y: 1))
                
                VStack (alignment: .leading) {
                    let room = model.reservation.roomName.split(separator: ":").first ?? ""
                    if let match = room.firstMatch(of: roomName) {
                        Text(match.1)
                            .foregroundColor(.white)
                            .font(.system(size: 40, weight: .bold))
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                    }
                    Text(model.reservation.gsr.name)
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .bold))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                }
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 3.35/9)

            Spacer()
                 
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    let startStr = timeFormatter.string(from: model.reservation.start)
                    let endStr = timeFormatter.string(from: model.reservation.end)
                    let timeRange = "\(startStr) - \(endStr)"

                    Text(timeRange)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                    let dateStr = dateFormatter.string(from: model.reservation.start)
                    Text(dateStr)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                if model.reservation.end < Date() {
                    Text("GSR Booking Expired")
                        .foregroundColor(.red)
                        .font(.system(size: 24, weight: .semibold))
                        .padding(40)
                } else {
                Button {
                    CalendarHelper.addToCalendar(
                        title: "GSR Booking: \(gsrLocation + " " + (room ?? ""))",
                        location: gsrLocation,
                        start: model.reservation.start,
                        end: model.reservation.end
                    ){ success in
                        if success {
                            showCalendarAlert = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Add to Calendar")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .alert(isPresented: $showCalendarAlert) {
                        Alert(
                            title: Text("Success"),
                            message: Text("Event was added to your Calendar."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    Button {
                        if let url = GoogleCalendarLink.makeURL(
                            title: "GSR Booking: \(gsrLocation) \(room ?? "")",
                            location: gsrLocation,
                            start: model.reservation.start,
                            end: model.reservation.end
                        ) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Google Calendar")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                }

                Text("Booked by \(model.userName)")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Spacer()

                let locationName = gsrLocation
                let coordinate = PennLocation.pennGSRLocation[locationName]?.coordinate
                    ?? CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1932)

                Map(coordinateRegion: $region, annotationItems: [Place(coordinate: coordinate)]) { place in
                    MapMarker(coordinate: place.coordinate, tint: .red)
                }
                .frame(height: 235)
                .cornerRadius(12)
                .onAppear {
                    region.center = coordinate
                }
                Spacer()
            }
            .padding()
        }
        .ignoresSafeArea()
    }
}


struct GSRShareDetailView_Previews: PreviewProvider {
    static var previews: some View {
//        let urlString = "gsr://share?data=eyJ1c2VyTmFtZSI6IlhpbWluZyIsInJlc2VydmF0aW9uIjp7ImJvb2tpbmdJZCI6ImNzX3Bid1ZWYWNnIiwiZW5kIjoiMjAyNS0wMy0wMlQxNTozMDowMFoiLCJzdGFydCI6IjIwMjUtMDMtMDJUMTU6MDA6MDBaIiwiZ3NyIjp7ImxpZCI6IjI1ODciLCJpbWFnZVVybCI6Imh0dHBzOlwvXC9zMy51cy1lYXN0LTIuYW1hem9uYXdzLmNvbVwvbGFicy5hcGlcL2dzclwvbGlkLTI1ODctZ2lkLTQzNjguanBnIiwia2luZCI6IkxJQkNBTCIsImdpZCI6NDM2OCwibmFtZSI6IkxpcHBpbmNvdHQifSwicm9vbU5hbWUiOiJbTWVdIFJvb20gMjQ4OiBDbGFzcyBvZiAxOTU1IENvbnN1bHRhdGlvbiBSb29tIiwicm9vbUlkIjoxNjk5MH19"
        let urlString = "gsr://share?data=eyJ1c2VyTmFtZSI6IlhpbWluZyIsInJlc2VydmF0aW9uIjp7InJvb21JZCI6NzE5Miwicm9vbU5hbWUiOiJbTWVdIEJvb3RoIDAxOiBTdHVkeSBCb290aCIsImdzciI6eyJnaWQiOjE4ODksImltYWdlVXJsIjoiaHR0cHM6XC9cL3MzLnVzLWVhc3QtMi5hbWF6b25hd3MuY29tXC9sYWJzLmFwaVwvZ3NyXC9saWQtMTA4Ni1naWQtMTg4OS5qcGciLCJsaWQiOiIxMDg2Iiwia2luZCI6IkxJQkNBTCIsIm5hbWUiOiJXZWlnbGUifSwic3RhcnQiOiIyMDI1LTAzLTE0VDE3OjAwOjAwWiIsImJvb2tpbmdJZCI6ImNzXzBYdnk4WEkyIiwiZW5kIjoiMjAyNS0wMy0xNFQxNzozMDowMFoifX0%3D"
        let manager = DeepLinkManager()
        var shareModel: GSRShareModel?

        if let encodedURL = URL(string: urlString) {
            manager.handleOpenURL(encodedURL)
            if let decoded = manager.lastResolvedLink {
                shareModel = decoded
            } else {
                print("Failed to decode from URL.")
            }
        } else {
            print("Failed to create URL from string.")
        }
        return Group {
            if let shareModel = shareModel {
                GSRShareDetailView(model: shareModel)
                    .previewLayout(.sizeThatFits)
            } else {
                Text("No share data found.")
            }
        }
    }
}

