//
//  GSRReservationDetailView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import MapKit

// view if you own the GSR
struct GSRReservationDetailView: View {
    var gsrReservation: GSRReservation
    
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @Environment(\.dismiss) var dismiss

    @State private var showCalendarAlert = false
    @State private var isLoading: Bool = true
    @State private var error: String?
    
    // gsr share
    @State private var isSharePresented = false
    @State private var shareURL: URL?
    @State private var isFetchingShareLink = false
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1932),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )

    // MARK: Helpers
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
    
    func displayShareUrl() async {
        isFetchingShareLink = true
        do {
            let link = try await GSRNetworkManager.getShareCodeLink(for: gsrReservation)
            isFetchingShareLink = false

            guard let url = URL(string: link) else {
                presentToast(.init(message: "Invalid share link"))
                return
            }

            shareURL = url
            isSharePresented = true

        } catch {
            print("\(error)")
            isFetchingShareLink = false
            presentToast(.init(message: "Unable to Fetch Share Link"))
        }
    }
    
    
    var body: some View {
        let model = gsrReservation
        let roomName = /\[Me\]\s*(.*)/
        let splitRoom = model.roomName.split(separator: ":").first ?? ""
        let room = splitRoom.firstMatch(of: roomName)?.1
        let gsrLocation = model.gsr.name
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Header Image
                ZStack(alignment: .bottomLeading) {
                    KFImage(URL(string: model.gsr.imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .black.opacity(0.6),
                            .black.opacity(0.2),
                            .clear,
                            .black.opacity(0.3),
                            .black
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let match = splitRoom.firstMatch(of: roomName) {
                            Text(match.1)
                                .foregroundColor(.white)
                                .font(.system(size: 38, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        
                        Text(model.gsr.name)
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding()
                }
                .frame(height: UIScreen.main.bounds.height * 0.38)
                .clipped()

                // MARK: Details Content
                VStack(alignment: .leading, spacing: 24) {

                    // booking details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Booking Details")
                            .font(.headline)

                        HStack {
                            let startStr = timeFormatter.string(from: model.start)
                            let endStr = timeFormatter.string(from: model.end)
                            let timeRange = "\(startStr) - \(endStr)"

                            Text(timeRange)
                                .font(.system(size: 18, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)

                            let dateStr = dateFormatter.string(from: model.start)

                            Text(dateStr)
                                .font(.system(size: 18, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }

                    Divider()
                    
                    // gsr share
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Share Reservation")
                            .font(.headline)

                        Button {
                            Task {
                                await displayShareUrl()
                            }
                        } label: {
                            HStack {
                                if (isFetchingShareLink) {
                                    ProgressView()
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share This Reservation")
                                }
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                    }
                    
                    Divider()
                    
                    // calendar
                    if model.end < Date() {
                        Text("GSR Booking Expired")
                            .foregroundColor(.red)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Calendar Options")
                                .font(.headline)

                            Button {
                                CalendarHelper.addToCalendar(
                                    title: "GSR Booking: \(gsrLocation + " " + (room ?? ""))",
                                    location: gsrLocation,
                                    start: model.start,
                                    end: model.end
                                ) { success in
                                    if success { showCalendarAlert = true }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("Add to Calendar")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }

                            Button {
                                if let url = GoogleCalendarLink.makeURL(
                                    title: "GSR Booking: \(gsrLocation) \(room ?? "")",
                                    location: gsrLocation,
                                    start: model.start,
                                    end: model.end
                                ) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("Google Calendar")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 1)
                                )
                            }
                        }
                    }

                    Divider()

                    // map location
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.headline)

                        let locationName = gsrLocation
                        let coordinate = PennLocation.pennGSRLocation[locationName]?.coordinate
                        ?? CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1932)

                        Map(coordinateRegion: $region, annotationItems: [Place(coordinate: coordinate)]) { place in
                            MapMarker(coordinate: place.coordinate, tint: .red)
                        }
                        .frame(height: 240)
                        .cornerRadius(12)
                        .onAppear { region.center = coordinate }
                    }

                    Divider()

                    // delete button
                    Button {
                        Task {
                            withAnimation {
                                vm.currentReservations.removeAll { $0.bookingId == gsrReservation.bookingId }
                            }
                            do { try await GSRNetworkManager.deleteReservation(gsrReservation) }
                            catch { presentToast(.init(message: "Unable to delete this reservation. Is it currently in progress?")) }

                            vm.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []

                            await MainActor.run { dismiss() }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Reservation")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }

                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}


