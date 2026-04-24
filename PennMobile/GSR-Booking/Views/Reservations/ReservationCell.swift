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
    
    private var roomName: String {
        let splitRoom = String(reservation.roomName.split(separator: ":").first ?? "")
        
        if splitRoom.hasPrefix("[Me]") {
            return splitRoom
                .dropFirst("[Me]".count)
                .trimmingCharacters(in: .whitespaces)
        } else {
            return splitRoom
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.5) {
            
            // MARK: Main Row
            HStack {
                
                KFImage(URL(string: reservation.gsr.imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 80)
                    .scaledToFill()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    )
                
                VStack(alignment: .leading) {
                    
                    Text(roomName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.labelPrimary)
                    
                    Text("\(reservation.start.gsrTimeString) - \(reservation.end.gsrTimeString)")
                        .font(.subheadline)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(Color.grey5)
                        .foregroundColor(.labelPrimary)
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
                    calendarButton
                    googleCalendarButton
                }
                
                Spacer()
                
                if FeatureFlags.shared.gsrShare {
                    shareButton
                }
                
                deleteButton
            }
        }
        .padding(.top, 5)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
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
        ZStack {
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
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.bottom, 2)
                        .foregroundColor(.secondary)
                }
            } else {
                ProgressView()
                    .frame(width: 20, height: 20)
            }
        }
        .frame(width: 40, height: 40)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .padding(.trailing, 9)
        .shadow(color: .black.opacity(0.2), radius: 4)
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
            Image("iCalendar")
                .resizable()
                .renderingMode(.original)
                .frame(width: 32, height: 32)
                .padding(8)
        }
        .frame(width: 40, height: 40)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .padding(.trailing, 9)
        .shadow(color: .black.opacity(0.2), radius: 4)
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
            Image("GoogleCalendar")
                .resizable()
                .renderingMode(.original)
                .frame(width: 32, height: 32)
                .padding(7)
        }
        .frame(width: 40, height: 40)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .padding(.leading, 9)
        .shadow(color: .black.opacity(0.2), radius: 4)
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
                    presentToast(
                        .init(
                            message: "Unable to delete this reservation. Is it currently in progress?"
                        )
                    )
                }
                
                vm.currentReservations =
                    (try? await GSRNetworkManager.getReservations()) ?? []
                
                await MainActor.run {
                    dismiss()
                }
            }
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.baseRed)
                .fontWeight(.semibold)
        }
        .frame(width: 40, height: 40)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .padding(.leading, 9)
        .shadow(color: .black.opacity(0.2), radius: 4)
    }
}
