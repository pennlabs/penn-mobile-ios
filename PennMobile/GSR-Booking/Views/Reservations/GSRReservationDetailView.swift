//
//  GSRReservationDetailView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRReservationDetailView: View {
    
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var gsrReservation: GSRReservation?
    @State private var error: String?
    
    let shareCode: String

    // MARK: Helpers

    private var roomName: String? {
        guard let model = gsrReservation else { return nil }
        let splitRoom = String(model.roomName.split(separator: ":").first ?? "")
        guard splitRoom.hasPrefix("[Me]") else { return nil }
        return splitRoom.dropFirst("[Me]".count).trimmingCharacters(in: .whitespaces)
    }

    // MARK: Body

    var body: some View {
        Group {
            if let model = gsrReservation {
                GSRReservationContentView(
                    model: model,
                    roomName: roomName
                )
            } else if let error {
                GSRReservationErrorView(message: error)
            } else {
                ProgressView("Loading reservation...")
            }
        }
        .task {
            do {
                gsrReservation = try await GSRNetworkManager.getShareModelFromShareCode(shareCode: shareCode)
            } catch let error as ShareCodeError {
                self.error = error.localizedDescription
            } catch {
                self.error = "Unable to get reservation details."
            }
        }
    }
}


