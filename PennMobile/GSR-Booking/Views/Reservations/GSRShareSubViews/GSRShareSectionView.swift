//
//  GSRShareSectionView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct GSRShareSectionView: View {
    let reservation: GSRReservation
    let shareURL: URL?
    let shareMessage: String?
    let isFetchingShareLink: Bool
    let onFetchShareLink: () -> Void
    
    @State private var sharePreviewImage: Image?
    
    var body: some View {
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
                .onAppear {
                    loadSharePreviewImage()
                }
            } else {
                Button {
                    onFetchShareLink()
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
    
    private func loadSharePreviewImage() {
        let imageUrlString = reservation.gsr.imageUrl
        if let imageUrl = URL(string: imageUrlString) {
            KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
                if case .success(let imageResult) = result {
                    sharePreviewImage = Image(uiImage: imageResult.image)
                }
            }
        }
    }
}
