//
//  GSRReservationContentView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRReservationContentView: View {
    let model: GSRReservation
    let mode: GSRReservationDetailView.Mode
    let roomName: String?
    let shareURL: URL?
    let shareMessage: String?
    let isFetchingShareLink: Bool
    let onFetchShareLink: () -> Void
    
    var body: some View {
        let gsrLocation = model.gsr.name

        ScrollView {
            VStack(spacing: 0) {
                GSRReservationHeaderView(model: model, roomName: roomName)

                VStack(alignment: .leading, spacing: 24) {

                    if mode.isReadOnly, let ownerName = model.ownerName {
                        Text("Booking Owner: \(ownerName)")
                            .font(.headline)
                        Divider()
                    }

                    GSRBookingDetailsView(model: model)

                    Divider()

                    if !mode.isReadOnly {
                        GSRShareSectionView(
                            reservation: model,
                            shareURL: shareURL,
                            shareMessage: shareMessage,
                            isFetchingShareLink: isFetchingShareLink,
                            onFetchShareLink: onFetchShareLink
                        )
                        Divider()
                    }

                    GSRCalendarSectionView(
                        model: model,
                        gsrLocation: gsrLocation,
                        roomName: roomName
                    )

                    Divider()

                    GSRMapSectionView(
                        model: model,
                        gsrLocation: gsrLocation,
                        roomName: roomName
                    )

                    if !mode.isReadOnly {
                        Divider()
                        
                        if case .owned(let reservation) = mode {
                            GSRDeleteButtonView(reservation: reservation)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
