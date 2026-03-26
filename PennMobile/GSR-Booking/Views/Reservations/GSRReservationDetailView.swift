//
//  GSRReservationDetailView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

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
    
    @MainActor func displayShareUrl() async {
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
        } catch {
            presentToast(.init(message: "Unable to fetch share link"))
        }
    }

    // MARK: Body

    var body: some View {
        Group {
            if let model = gsrReservation {
                GSRReservationContentView(
                    model: model,
                    mode: mode,
                    roomName: roomName,
                    shareURL: shareURL,
                    shareMessage: shareMessage,
                    isFetchingShareLink: isFetchingShareLink,
                    onFetchShareLink: { Task { await displayShareUrl() } }
                )
            } else if let error {
                GSRReservationErrorView(message: error)
            } else {
                ProgressView("Loading reservation...")
            }
        }
        .task {
            guard case .shared(let shareCode) = mode else { return }
            do {
                gsrReservation = try await GSRNetworkManager.getShareModelFromShareCode(shareCode: shareCode)
                isLoading = false
            } catch let error as ShareCodeError {
                self.error = error.localizedDescription
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}


