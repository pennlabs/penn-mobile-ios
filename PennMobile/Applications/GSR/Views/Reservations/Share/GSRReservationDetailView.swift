//
//  GSRReservationDetailView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

/// Shows a reservation someone shared via a share link
struct GSRReservationDetailView: View {
    private let endpoint: PennMobileApplication.GSR.GetSharedReservation
    @BackendFetched<PennMobileApplication.GSR.GetSharedReservation> var reservation: BackendFetchedResult<GSRReservation>

    init(shareCode: String) {
        endpoint = PennMobileApplication.GSR.GetSharedReservation(shareCode: shareCode)
        _reservation = BackendFetched(endpoint)
    }

    var body: some View {
        switch reservation {
        case .success(let model) where model.isValid == true:
            GSRReservationContentView(model: model, roomName: model.sharedRoomName)
        case .success:
            GSRReservationErrorView(message: ShareCodeError.expiredGSR.localizedDescription)
        case .failure(let error):
            GSRReservationErrorView(message: String(localized: endpoint.errorResponse(error: error).accessibilityAnnouncement))
        case .pending:
            ProgressView("Loading reservation...")
        }
    }
}

private extension GSRReservation {
    /// The room name with the "[Me]" prefix and ":"-suffix stripped, if the room name has that format
    var sharedRoomName: String? {
        let splitRoom = String(roomName.split(separator: ":").first ?? "")
        guard splitRoom.hasPrefix("[Me]") else { return nil }
        return splitRoom.dropFirst("[Me]".count).trimmingCharacters(in: .whitespaces)
    }
}
