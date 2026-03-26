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

struct GSRReservationDetailView: View {
    
    // enum storing owned and shared tags
    enum Mode {
        case owned(GSRReservation)
        case shared(shareCode: String)

        var isReadOnly: Bool {
            if case .shared = self { return true }
            return false
        }
    }

    let mode: Mode

    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @Environment(\.dismiss) var dismiss

    @State private var gsrReservation: GSRReservation?
    @State private var isLoading = true
    @State private var error: String?

    // share
    @State private var shareURL: URL?
    @State private var isFetchingShareLink = false
    @State private var sharePreviewImage: Image?

    @State var position: MapCameraPosition = .automatic

    // MARK: Formatters

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()

    private let timeFormatter: DateFormatter = {
        let tf = DateFormatter()
        tf.timeStyle = .short
        return tf
    }()

    // MARK: Init

    init(mode: Mode) {
        self.mode = mode
        if case .owned(let reservation) = mode {
            _gsrReservation = State(initialValue: reservation)
            _isLoading = State(initialValue: false)
        }
    }

    // MARK: Helpers

    private var roomName: String? {
        guard let model = gsrReservation else { return nil }
        let splitRoom = String(model.roomName.split(separator: ":").first ?? "")
        guard splitRoom.hasPrefix("[Me]") else { return nil }
        return splitRoom.dropFirst("[Me]".count).trimmingCharacters(in: .whitespaces)
    }
    
    private var shareMessage: String? {
        guard let model = gsrReservation else { return nil }
        let dateStr = dateFormatter.string(from: model.start)
        let startStr = timeFormatter.string(from: model.start)
        let endStr = timeFormatter.string(from: model.end)
        return "GSR reservation: \(model.gsr.name) • \(dateStr) • \(startStr)–\(endStr)"
    }
    
    func displayShareUrl() async {
        guard case .owned(let reservation) = mode else { return }
        isFetchingShareLink = true
        defer { isFetchingShareLink = false }
        do {
            let link = try await GSRNetworkManager.getShareCodeLink(for: reservation)
            guard let url = URL(string: link) else {
                presentToast(.init(message: "Server failed to generate a share link"))
                return
            }
            shareURL = url
            
            // Load the image for share preview
            await loadSharePreviewImage()
        } catch {
            presentToast(.init(message: "Unable to fetch share link"))
        }
    }
    
    private func loadSharePreviewImage() async {
        guard let imageUrlString = gsrReservation?.gsr.imageUrl,
              let imageUrl = URL(string: imageUrlString) else {
            sharePreviewImage = Image(systemName: "calendar")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            if let uiImage = UIImage(data: data) {
                sharePreviewImage = Image(uiImage: uiImage)
            } else {
                sharePreviewImage = Image(systemName: "calendar")
            }
        } catch {
            sharePreviewImage = Image(systemName: "calendar")
        }
    }

    // MARK: Body

    var body: some View {
        Group {
            if let model = gsrReservation {
                content(model: model)
            } else if let error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView()
            }
        }
        .task {
            guard case .shared(let shareCode) = mode else { return }
            do {
                gsrReservation = try await GSRNetworkManager.getShareModelFromShareCode(shareCode: shareCode)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    // MARK: Main Content

    @ViewBuilder
    private func content(model: GSRReservation) -> some View {
        let gsrLocation = model.gsr.name

        ScrollView {
            VStack(spacing: 0) {
                headerImage(model: model)

                VStack(alignment: .leading, spacing: 24) {

                    if mode.isReadOnly, let ownerName = model.ownerName {
                        Text("Booking Owner: \(ownerName)")
                            .font(.headline)
                        Divider()
                    }

                    bookingDetails(model: model)

                    Divider()

                    if !mode.isReadOnly {
                        shareSection()
                        Divider()
                    }

                    calendarSection(model: model, gsrLocation: gsrLocation)

                    Divider()

                    mapSection(model: model, gsrLocation: gsrLocation)

                    if !mode.isReadOnly {
                        Divider()
                        deleteButton()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: Subviews

    @ViewBuilder
    private func headerImage(model: GSRReservation) -> some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: model.gsr.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [
                    .black.opacity(0.6), .black.opacity(0.2),
                    .clear, .black.opacity(0.3), .black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(roomName ?? model.roomName)
                    .foregroundColor(.white)
                    .font(.system(size: 38, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)

                Text(model.gsr.name)
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            .padding()
        }
        .frame(height: UIScreen.main.bounds.height * 0.38)
        .clipped()
    }

    @ViewBuilder
    private func bookingDetails(model: GSRReservation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Booking Details").font(.headline)

            HStack {
                Text("\(timeFormatter.string(from: model.start)) - \(timeFormatter.string(from: model.end))")
                    .detailChip()

                Text(dateFormatter.string(from: model.start))
                    .detailChip()
            }
        }
    }

    @ViewBuilder
    private func shareSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share Reservation").font(.headline)

            if let url = shareURL, let message = shareMessage {
                ShareLink(
                    item: url,
                    subject: Text("GSR Reservation"),
                    message: Text(message),
                    preview: SharePreview(
                        message,
                        image: sharePreviewImage ?? Image(systemName: "calendar")
                    )
                ) {
                    Label("Share This Reservation", systemImage: "square.and.arrow.up")
                        .calendarButton(style: .blueFilled)
                }
            } else {
                Button {
                    Task { await displayShareUrl() }
                } label: {
                    Group {
                        if isFetchingShareLink {
                            ProgressView()
                        } else {
                            Label("Open Reservation for Sharing", systemImage: "link")
                        }
                    }
                    .calendarButton(style: .redOutline)
                }
                .disabled(isFetchingShareLink)
            }
        }
    }

    @ViewBuilder
    private func calendarSection(model: GSRReservation, gsrLocation: String) -> some View {
        if model.end < Date() {
            Text("GSR Booking Expired")
                .foregroundColor(.red)
                .font(.system(size: 20, weight: .semibold))
                .padding(.vertical, 8)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Calendar Options").font(.headline)

                Button {
                    Task {
                        do {
                            try await CalendarHelper.addToCalendar(
                                title: "GSR Booking: \(gsrLocation) \(roomName ?? model.roomName)",
                                location: gsrLocation,
                                start: model.start,
                                end: model.end
                            )
                            presentToast(.init(message: "Added to calendar!"))
                        } catch CalendarError.accessDenied {
                            presentToast(.init(message: "Calendar access denied. Please enable it in Settings."))
                        } catch {
                            presentToast(.init(message: "Failed to add event to calendar."))
                        }
                    }
                } label: {
                    Label("Add to Calendar", systemImage: "calendar")
                        .calendarButton(style: .blueFilled)
                }

                Button {
                    if let url = GoogleCalendarLink.makeURL(
                        title: "GSR Booking: \(gsrLocation) \(roomName ?? model.roomName)",
                        location: gsrLocation,
                        start: model.start,
                        end: model.end
                    ) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Google Calendar", systemImage: "calendar")
                        .calendarButton(style: .whiteOutline)
                }
            }
        }
    }

    @ViewBuilder
    private func mapSection(model: GSRReservation, gsrLocation: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location").font(.headline)

            if let coordinate = PennLocation.pennGSRLocation[gsrLocation]?.coordinate {
                Map(position: $position) {
                    UserAnnotation()
                    Marker("\(model.gsr.name), \(roomName ?? model.roomName)", coordinate: coordinate)
                }
                .frame(height: 240)
                .cornerRadius(12)
                .onAppear {
                    position = .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    ))
                }
            } else {
                HStack {
                    Image(systemName: "mappin.slash")
                    Text("Location not available")
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private func deleteButton() -> some View {
        if case .owned(let reservation) = mode {
            Button {
            Task {
                withAnimation {
                    vm.currentReservations.removeAll { $0.bookingId == reservation.bookingId }
                }
                do { try await GSRNetworkManager.deleteReservation(reservation) }
                catch { presentToast(.init(message: "Unable to delete this reservation. Is it currently in progress?")) }
                vm.currentReservations = (try? await GSRNetworkManager.getReservations()) ?? []
                await MainActor.run { dismiss() }
            }
        } label: {
            Label("Delete Reservation", systemImage: "trash")
                .calendarButton(style: .redOutline)
                .foregroundColor(.red)
        }
        }
    }
}

// MARK: - Button Style Helper

private enum ButtonStyle { case blueFilled, redOutline, whiteOutline }

private extension View {
    @ViewBuilder
    func calendarButton(style: ButtonStyle) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .padding()
            .frame(maxWidth: .infinity)
            .background(style == .blueFilled ? Color.blue : style == .redOutline ? Color.baseRed.opacity(0.1) : Color.white)
            .foregroundColor(style == .blueFilled ? .white : style == .redOutline ? .baseRed : .black)
            .overlay(style == .whiteOutline ? RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1) : nil)
            .cornerRadius(10)
    }

    func detailChip() -> some View {
        self
            .font(.system(size: 18, weight: .medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
    }
}

