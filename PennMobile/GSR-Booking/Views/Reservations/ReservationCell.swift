//
//  ReservationCell.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct ReservationCell: View {
    
    let reservation: GSRReservation
    let height: CGFloat = 100
    
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoadingShare = false
    @State private var shareURL: URL?
    @State private var prefetchedShareURL: URL?
    @State private var sharePreviewImage: Image?
    
    private var shareMessage: String {
            let dateFormatter: DateFormatter = {
                let df = DateFormatter()
                df.dateStyle = .short
                df.timeStyle = .none
                return df
            }()
            let timeFormatter: DateFormatter = {
                let tf = DateFormatter()
                tf.timeStyle = .short
                return tf
            }()
            let dateStr = dateFormatter.string(from: reservation.start)
            let startStr = timeFormatter.string(from: reservation.start)
            let endStr = timeFormatter.string(from: reservation.end)
            return "GSR reservation: \(reservation.gsr.name) • \(dateStr) • \(startStr)–\(endStr)"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: Main Row
            HStack {
                
                KFImage(URL(string: reservation.gsr.imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 80)
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    
                    Text(reservation.roomName)
                        .font(.subheadline)
                        .foregroundStyle(.labelPrimary)
                    
                    Text("\(reservation.start.gsrTimeString) - \(reservation.end.gsrTimeString)")
                        .font(.subheadline)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .foregroundColor(.labelPrimary)
                        .background(Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.leading, 16)
                
                Spacer()
                
            }
            .frame(height: height)
            .cornerRadius(8)
            .transition(.blurReplace)
            
            // MARK: Inline Actions
            HStack {
                
                if FeatureFlags.shared.gsrShare {
                    shareButton
                    calendarButton
                    googleCalendarButton
                }
                
                Spacer()
                
                deleteButton
            }
        }
        .padding()
        .task {
                    guard FeatureFlags.shared.gsrShare, prefetchedShareURL == nil else { return }
                    
                    // Prefetch share link
                    isLoadingShare = true
                    defer { isLoadingShare = false }
                    
                    if let link = try? await GSRNetworkManager.getShareCodeLink(for: reservation),
                       let url = URL(string: link) {
                        prefetchedShareURL = url
                    }
                    
                    // Prefetch preview image
                    if let imageUrl = URL(string: reservation.gsr.imageUrl) {
                        KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
                            if case .success(let imageResult) = result {
                                sharePreviewImage = Image(uiImage: imageResult.image)
                            }
                        }
                    }
        }
    }
}

// MARK: - Subviews
private extension ReservationCell {
    
    var shareButton: some View {
        Group {
            if let url = prefetchedShareURL {
                ShareLink(
                    item: url,
                    subject: Text("GSR Reservation"),
                    message: Text(shareMessage),
                    preview: SharePreview(
                        shareMessage,
                        image: sharePreviewImage ?? Image(systemName: "calendar")
                    )
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            } else {
                ProgressView()
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    var calendarButton: some View {
        Button {
            Task {
                do {
                    try await CalendarHelper.addToCalendar(
                        title: "GSR Booking: \(reservation.gsr.name) \(reservation.roomName)",
                        location: reservation.gsr.name,
                        start: reservation.start,
                        end: reservation.end
                    )
                    presentToast(.init(message: "Added to calendar!"))
                    
                } catch CalendarError.accessDenied {
                    presentToast(.init(message: "Calendar access denied. Please enable it in Settings."))
                    
                } catch {
                    presentToast(.init(message: "Failed to add event to calendar."))
                }
            }
        } label: {
            Text("iCal")
                .calendarButton(style: .blueFilled)
        }
    }
    
    var googleCalendarButton: some View {
        Button {
            if let url = GoogleCalendarLink.makeURL(
                title: "GSR Booking: \(reservation.gsr.name) \(reservation.roomName)",
                location: reservation.gsr.name,
                start: reservation.start,
                end: reservation.end
            ) {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("GCal")
                .calendarButton(style: .redOutline)
        }
    }
    
    var deleteButton: some View {
        Button {
            Task {
                withAnimation {
                    vm.currentReservations.removeAll {
                        $0.bookingId == reservation.bookingId
                    }
                }
                
                do {
                    try await GSRNetworkManager.deleteReservation(reservation)
                } catch {
                    presentToast(.init(
                        message: "Unable to delete this reservation. Is it currently in progress?"
                    ))
                }
                
                vm.currentReservations =
                    (try? await GSRNetworkManager.getReservations()) ?? []
                
                await MainActor.run {
                    dismiss()
                }
            }
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
    }
}
